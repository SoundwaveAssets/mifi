package com.assoumou.mifi

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat

/** Notifications : canaux (noms traduits par Dart) et affichage. */
object Notifications {
    const val FALLBACK_CHANNEL = "alerts"
    private const val WORK_CHANNEL = "background_work"

    fun enabled(context: Context): Boolean {
        val permitted = Build.VERSION.SDK_INT < 33 ||
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        return permitted && NotificationManagerCompat.from(context).areNotificationsEnabled()
    }

    fun ensureChannels(context: Context, channels: List<Map<String, Any?>>) {
        if (Build.VERSION.SDK_INT < 26) return
        val manager = context.getSystemService(NotificationManager::class.java)
        for (spec in channels) {
            val id = spec["id"] as? String ?: continue
            val importance = if (spec["highImportance"] == true) {
                NotificationManager.IMPORTANCE_HIGH
            } else {
                NotificationManager.IMPORTANCE_DEFAULT
            }
            val channel = NotificationChannel(id, spec["name"] as? String ?: id, importance)
            channel.description = spec["description"] as? String
            manager.createNotificationChannel(channel)
        }
    }

    fun show(
        context: Context,
        id: Int,
        channelId: String,
        title: String,
        body: String,
        route: String?,
        actionLabel: String?,
        actionRoute: String?,
    ) {
        if (!enabled(context)) return
        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_stat_mifi)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setAutoCancel(true)
            .setContentIntent(openApp(context, id * 2, route))
        if (actionLabel != null && actionRoute != null) {
            builder.addAction(0, actionLabel, openApp(context, id * 2 + 1, actionRoute))
        }
        runCatching { NotificationManagerCompat.from(context).notify(id, builder.build()) }
    }

    /** Notification discrète des travaux WorkManager accélérés (Android < 12). */
    fun workNotification(context: Context): Notification {
        if (Build.VERSION.SDK_INT >= 26) {
            val manager = context.getSystemService(NotificationManager::class.java)
            if (manager.getNotificationChannel(WORK_CHANNEL) == null) {
                manager.createNotificationChannel(
                    NotificationChannel(
                        WORK_CHANNEL,
                        context.getString(R.string.background_channel_name),
                        NotificationManager.IMPORTANCE_LOW,
                    )
                )
            }
        }
        return NotificationCompat.Builder(context, WORK_CHANNEL)
            .setSmallIcon(R.drawable.ic_stat_mifi)
            .setContentTitle(context.getString(R.string.app_name))
            .setContentText(context.getString(R.string.background_work_text))
            .setOngoing(true)
            .setSilent(true)
            .build()
    }

    /** Ouvre l'appli, éventuellement sur un écran donné. */
    fun openApp(context: Context, requestCode: Int, route: String?): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        if (route != null) intent.putExtra(MainActivity.EXTRA_ROUTE, route)
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }
}
