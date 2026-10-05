package com.assoumou.mifi

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Surveillance continue de la connexion, appli fermée : service au premier
 * plan (notification discrète « Surveillance active ») qui fait tourner
 * `monitorMain` (Dart) dans son propre moteur Flutter. Les relevés sont
 * espacés quand tout va bien et rapprochés quand internet ne passe plus ;
 * aucun verrou d'éveil : en veille profonde, Android les espace encore.
 */
class MonitorService : Service() {
    private var engine: FlutterEngine? = null
    private var bridge: NativeBridge? = null

    override fun onCreate() {
        super.onCreate()
        val notification = notification(this)
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        startEngine()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        if (AppEngineHolder.monitorBridge === bridge) AppEngineHolder.monitorBridge = null
        bridge?.detach()
        engine?.destroy()
        bridge = null
        engine = null
        super.onDestroy()
    }

    private fun startEngine() {
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(applicationContext)
        loader.ensureInitializationComplete(applicationContext, null)
        val created = FlutterEngine(applicationContext)
        val createdBridge = NativeBridge(applicationContext, created, null)
        engine = created
        bridge = createdBridge
        AppEngineHolder.monitorBridge = createdBridge
        created.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "monitorMain"),
        )
    }

    companion object {
        private const val CHANNEL = "monitor"
        private const val NOTIFICATION_ID = 4243
        private const val PREFS = "mifi_native"
        private const val KEY_ENABLED = "monitor_enabled"

        /** Surveillance voulue par l'utilisateur (relancée au démarrage du téléphone). */
        fun isEnabled(context: Context): Boolean =
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(KEY_ENABLED, false)

        /** Active et démarre la surveillance (sans effet si elle tourne déjà). */
        fun start(context: Context): Boolean {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(KEY_ENABLED, true).apply()
            return resume(context)
        }

        /** Redémarre la surveillance si elle est voulue (démarrage du téléphone, mise à jour). */
        fun resume(context: Context): Boolean = isEnabled(context) && runCatching {
            ContextCompat.startForegroundService(context, Intent(context, MonitorService::class.java))
            true
        }.getOrDefault(false)

        /** Désactive et arrête la surveillance. */
        fun stop(context: Context) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(KEY_ENABLED, false).apply()
            context.stopService(Intent(context, MonitorService::class.java))
        }

        private fun notification(context: Context) = run {
            if (Build.VERSION.SDK_INT >= 26) {
                val manager = context.getSystemService(NotificationManager::class.java)
                manager.createNotificationChannel(
                    NotificationChannel(
                        CHANNEL,
                        context.getString(R.string.monitor_channel_name),
                        NotificationManager.IMPORTANCE_LOW,
                    ).apply { setShowBadge(false) },
                )
            }
            NotificationCompat.Builder(context, CHANNEL)
                .setSmallIcon(R.drawable.ic_stat_mifi)
                .setContentTitle(context.getString(R.string.monitor_notification_title))
                .setContentText(context.getString(R.string.monitor_notification_text))
                .setContentIntent(Notifications.openApp(context, 9, null))
                .setOngoing(true)
                .setSilent(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
                .build()
        }
    }
}
