package com.assoumou.mifi

import android.Manifest
import android.content.Intent
import android.net.Uri
import android.net.wifi.WifiNetworkSuggestion
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Activité principale. Hérite de FlutterFragmentActivity (exigé par le
 * verrouillage par empreinte) et expose au pont natif les fonctions qui ont
 * besoin d'une activité : enregistrement de fichier, autorisation des
 * notifications, partage, écran allumé, écran demandé au lancement.
 */
class MainActivity : FlutterFragmentActivity() {
    private var bridge: NativeBridge? = null
    private var launchRoute: String? = null

    private var pendingSave: Pair<ByteArray, (Boolean) -> Unit>? = null
    private val saveLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        val (bytes, callback) = pendingSave ?: return@registerForActivityResult
        pendingSave = null
        val uri: Uri? = result.data?.data
        if (result.resultCode != RESULT_OK || uri == null) {
            callback(false)
            return@registerForActivityResult
        }
        val ok = runCatching {
            contentResolver.openOutputStream(uri, "wt")?.use { it.write(bytes) } != null
        }.getOrDefault(false)
        callback(ok)
    }

    private var pendingPermission: ((Boolean) -> Unit)? = null
    private val permissionLauncher = registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
        pendingPermission?.invoke(granted)
        pendingPermission = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Seulement au vrai lancement : pas après une recréation de l'activité
        // ni depuis les applis récentes (le raccourci se rejouerait).
        val fromHistory = ((intent?.flags ?: 0) and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0
        if (savedInstanceState == null && !fromHistory) launchRoute = intent?.getStringExtra(EXTRA_ROUTE)
        intent?.removeExtra(EXTRA_ROUTE)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val created = NativeBridge(applicationContext, flutterEngine, this)
        bridge = created
        AppEngineHolder.mainBridge = created
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        if (AppEngineHolder.mainBridge === bridge) AppEngineHolder.mainBridge = null
        bridge?.detach()
        bridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onResume() {
        super.onResume()
        AppEngineHolder.isResumed = true
    }

    override fun onPause() {
        AppEngineHolder.isResumed = false
        super.onPause()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val route = intent.getStringExtra(EXTRA_ROUTE)
        intent.removeExtra(EXTRA_ROUTE)
        setIntent(intent)
        if (route == null) return
        bridge?.openRoute(route) ?: run { launchRoute = route }
    }

    /** Écran demandé au lancement (raccourci, notification), une seule fois. */
    fun takeLaunchRoute(): String? = launchRoute.also { launchRoute = null }

    fun setKeepScreenOn(on: Boolean) = runOnUiThread {
        if (on) window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        else window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    fun requestNotificationPermission(callback: (Boolean) -> Unit) {
        if (Build.VERSION.SDK_INT < 33 || Notifications.enabled(this)) {
            callback(Notifications.enabled(this))
            return
        }
        pendingPermission = callback
        permissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
    }

    fun saveDocument(fileName: String, mimeType: String, bytes: ByteArray, callback: (Boolean) -> Unit) {
        pendingSave?.second?.invoke(false)
        pendingSave = bytes to callback
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT)
            .addCategory(Intent.CATEGORY_OPENABLE)
            .setType(mimeType)
            .putExtra(Intent.EXTRA_TITLE, fileName)
        runCatching { saveLauncher.launch(intent) }.onFailure {
            pendingSave = null
            callback(false)
        }
    }

    fun shareText(text: String, title: String?) {
        val send = Intent(Intent.ACTION_SEND).setType("text/plain").putExtra(Intent.EXTRA_TEXT, text)
        startActivity(Intent.createChooser(send, title))
    }

    /**
     * Propose d'enregistrer le réseau Wi-Fi avec son nouveau mot de passe :
     * boîte système sur Android 11+, sinon réglages Wi-Fi.
     */
    fun suggestWifiNetwork(ssid: String, password: String, hidden: Boolean): Boolean = runCatching {
        if (Build.VERSION.SDK_INT >= 30) {
            val builder = WifiNetworkSuggestion.Builder().setSsid(ssid).setIsHiddenSsid(hidden)
            if (password.isNotEmpty()) builder.setWpa2Passphrase(password)
            val list = arrayListOf(builder.build())
            startActivity(Intent(Settings.ACTION_WIFI_ADD_NETWORKS).putParcelableArrayListExtra(Settings.EXTRA_WIFI_NETWORK_LIST, list))
        } else if (Build.VERSION.SDK_INT >= 29) {
            startActivity(Intent(Settings.Panel.ACTION_WIFI))
        } else {
            startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
        }
        true
    }.getOrDefault(false)

    companion object {
        const val EXTRA_ROUTE = "com.assoumou.mifi.ROUTE"
    }
}

/** Moteur principal vivant (appli ouverte) et visibilité de l'activité. */
object AppEngineHolder {
    @Volatile var mainBridge: NativeBridge? = null
    @Volatile var isResumed: Boolean = false

    /** Moteur de la surveillance continue (service), s'il tourne. */
    @Volatile var monitorBridge: NativeBridge? = null
}
