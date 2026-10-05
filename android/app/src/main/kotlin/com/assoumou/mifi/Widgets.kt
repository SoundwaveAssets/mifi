package com.assoumou.mifi

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

/** Derniers textes du widget d'état (publiés par Dart, déjà traduits). */
object StatusWidgetStore {
    private const val PREFS = "mifi_status_widget"

    fun write(context: Context, values: Map<*, *>) {
        val editor = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
        for ((key, value) in values) {
            when (value) {
                is String -> editor.putString(key.toString(), value)
                is Int -> editor.putInt(key.toString(), value)
                is Boolean -> editor.putBoolean(key.toString(), value)
                is Number -> editor.putInt(key.toString(), value.toInt())
            }
        }
        editor.apply()
    }

    fun string(context: Context, key: String): String? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(key, null)

    fun int(context: Context, key: String): Int =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getInt(key, 0)

    fun bool(context: Context, key: String): Boolean =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(key, false)
}

/** Widget d'état : opérateur, signal, internet, appareils. Un appui ouvre l'appli. */
class StatusWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) = render(context, manager, ids)

    companion object {
        private val signalIcons = intArrayOf(
            R.drawable.ic_signal_0, R.drawable.ic_signal_1, R.drawable.ic_signal_2,
            R.drawable.ic_signal_3, R.drawable.ic_signal_4,
        )

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            render(context, manager, manager.idsOf(context, StatusWidgetProvider::class.java))
        }

        private fun render(context: Context, manager: AppWidgetManager, ids: IntArray) {
            if (ids.isEmpty()) return
            val views = RemoteViews(context.packageName, R.layout.widget_status)
            views.setTextViewText(
                R.id.status_operator,
                StatusWidgetStore.string(context, "operator") ?: context.getString(R.string.app_name),
            )
            views.setTextViewText(R.id.status_signal, StatusWidgetStore.string(context, "signal") ?: "—")
            views.setImageViewResource(
                R.id.status_signal_icon,
                signalIcons[StatusWidgetStore.int(context, "signalBars").coerceIn(0, 4)],
            )
            views.setTextViewText(
                R.id.status_internet,
                StatusWidgetStore.string(context, "internet") ?: context.getString(R.string.status_widget_waiting),
            )
            views.setImageViewResource(
                R.id.status_internet_icon,
                if (StatusWidgetStore.bool(context, "internetOk")) R.drawable.ic_internet_on else R.drawable.ic_internet_off,
            )
            views.setTextViewText(R.id.status_devices, StatusWidgetStore.string(context, "devices") ?: "")
            views.setOnClickPendingIntent(R.id.status_root, Notifications.openApp(context, 7, null))
            manager.updateAppWidget(ids, views)
        }
    }
}
