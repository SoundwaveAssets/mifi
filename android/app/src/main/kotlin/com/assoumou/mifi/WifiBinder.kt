package com.assoumou.mifi

import android.content.Context
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import java.net.HttpURLConnection
import java.net.Inet4Address
import java.net.URL
import java.util.concurrent.Callable
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

/**
 * Force les requêtes de l'appli à passer par le Wi-Fi (le modem), même
 * quand Android le marque « sans internet » et préfère les données mobiles :
 * le processus est lié au réseau Wi-Fi avec bindProcessToNetwork.
 */
class WifiBinder private constructor(context: Context) {
    private val cm = context.applicationContext.getSystemService(ConnectivityManager::class.java)

    @Volatile private var wifiNetwork: Network? = null
    @Volatile private var validated = false
    @Volatile private var links: LinkProperties? = null
    private var registered = false

    private val callback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            wifiNetwork = network
            cm.bindProcessToNetwork(network)
        }

        override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) {
            if (network == wifiNetwork) validated = caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
        }

        override fun onLinkPropertiesChanged(network: Network, linkProperties: LinkProperties) {
            if (network == wifiNetwork) links = linkProperties
        }

        override fun onLost(network: Network) {
            if (network == wifiNetwork) {
                wifiNetwork = null
                links = null
                validated = false
                cm.bindProcessToNetwork(null)
            }
        }
    }

    @Synchronized
    fun bind(): Status {
        if (!registered) {
            val request = NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .build()
            runCatching { cm.requestNetwork(request, callback) }
                .onSuccess { registered = true }
        }
        val network = wifiNetwork ?: findWifi()
        if (network != null) {
            wifiNetwork = network
            if (links == null) links = cm.getLinkProperties(network)
            validated = cm.getNetworkCapabilities(network)
                ?.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) == true
            cm.bindProcessToNetwork(network)
        }
        return status()
    }

    fun status(): Status {
        val network = wifiNetwork ?: findWifi()
        val props = links ?: network?.let { cm.getLinkProperties(it) }
        val gateway = props?.routes
            ?.firstOrNull { it.isDefaultRoute && it.gateway is Inet4Address }
            ?.gateway?.hostAddress
        val address = props?.linkAddresses?.firstOrNull { it.address is Inet4Address }
        return Status(
            wifiConnected = network != null,
            bound = network != null && cm.boundNetworkForProcess == network,
            validated = network != null && validated,
            gateway = gateway,
            ipAddress = address?.address?.hostAddress,
            prefixLength = address?.prefixLength,
        )
    }

    /**
     * Internet passe-t-il réellement par le Wi-Fi du modem ? Même test
     * qu'Android : une page qui répond « 204 » seulement si internet passe
     * (un portail captif, ex. SIM sans forfait, répond autre chose).
     * Uniquement sur le réseau Wi-Fi ; `null` sans Wi-Fi. À appeler hors du
     * fil principal.
     */
    fun probeInternet(): Boolean? {
        val network = wifiNetwork ?: findWifi() ?: return null
        val first = probeExecutor.submit(Callable { probe(network, PROBE_URLS[0]) })
        if (runCatching { first.get(SECOND_PROBE_AFTER_MS, TimeUnit.MILLISECONDS) }.getOrNull() == true) return true
        // Réponse lente ou absente : second serveur en parallèle, le premier
        // « oui » l'emporte. Délai total borné (une résolution DNS bloquée
        // n'est pas couverte par les délais de connexion).
        val second = probeExecutor.submit(Callable { probe(network, PROBE_URLS[1]) })
        val deadline = System.currentTimeMillis() + PROBE_DEADLINE_MS
        try {
            while (System.currentTimeMillis() < deadline) {
                if (first.isDone && runCatching { first.get() }.getOrDefault(false)) return true
                if (second.isDone && runCatching { second.get() }.getOrDefault(false)) return true
                if (first.isDone && second.isDone) return false
                Thread.sleep(50)
            }
            return false
        } finally {
            first.cancel(true)
            second.cancel(true)
        }
    }

    private fun probe(network: Network, url: String): Boolean = runCatching {
        val connection = network.openConnection(URL(url)) as HttpURLConnection
        try {
            connection.connectTimeout = PROBE_TIMEOUT_MS
            connection.readTimeout = PROBE_TIMEOUT_MS
            connection.instanceFollowRedirects = false
            connection.useCaches = false
            connection.responseCode == 204
        } finally {
            connection.disconnect()
        }
    }.getOrDefault(false)

    /** Réseau Wi-Fi du modem (pas le point d'accès du téléphone, qui est aussi « Wi-Fi »). */
    @Suppress("DEPRECATION")
    private fun findWifi(): Network? {
        val wifi = cm.allNetworks.filter {
            cm.getNetworkCapabilities(it)?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true
        }
        return wifi.firstOrNull {
            cm.getNetworkCapabilities(it)?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true
        } ?: wifi.firstOrNull()
    }

    data class Status(
        val wifiConnected: Boolean,
        val bound: Boolean,
        val validated: Boolean,
        val gateway: String?,
        val ipAddress: String?,
        val prefixLength: Int?,
    ) {
        fun toMap(): Map<String, Any?> = mapOf(
            "wifiConnected" to wifiConnected,
            "bound" to bound,
            "validated" to validated,
            "gateway" to gateway,
            "ipAddress" to ipAddress,
            "prefixLength" to prefixLength,
        )
    }

    companion object {
        private val PROBE_URLS = listOf(
            "http://connectivitycheck.gstatic.com/generate_204",
            "http://cp.cloudflare.com/generate_204",
        )
        private const val PROBE_TIMEOUT_MS = 2500
        private const val SECOND_PROBE_AFTER_MS = 800L
        private const val PROBE_DEADLINE_MS = 5000L
        private val probeExecutor = Executors.newCachedThreadPool()

        @Volatile private var instance: WifiBinder? = null

        fun get(context: Context): WifiBinder =
            instance ?: synchronized(this) { instance ?: WifiBinder(context).also { instance = it } }
    }
}
