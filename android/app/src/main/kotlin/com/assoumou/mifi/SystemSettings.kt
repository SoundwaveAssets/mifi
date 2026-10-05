package com.assoumou.mifi

import android.app.Activity
import android.app.AlarmManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings

/**
 * Réglages système dont dépendent les tâches programmées appli fermée :
 * alarmes exactes, démarrage automatique (Xiaomi), batterie.
 */
object SystemSettings {
    /** Alarmes exactes autorisées (toujours vrai avant Android 12). */
    fun canScheduleExactAlarms(context: Context): Boolean =
        Build.VERSION.SDK_INT < 31 || context.getSystemService(AlarmManager::class.java).canScheduleExactAlarms()

    /** Autorisation « Alarmes et rappels » de l'appli (Android 12+). */
    fun openExactAlarmSettings(context: Context): Boolean =
        Build.VERSION.SDK_INT >= 31 &&
            start(context, Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, packageUri(context)))

    /** Démarrage automatique (Xiaomi, HyperOS), sinon la fiche de l'appli. */
    fun openAutostartSettings(context: Context): Boolean =
        start(
            context,
            Intent().setComponent(
                ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
            ),
        ) || openAppSettings(context)

    /** L'appli peut-elle fonctionner en arrière-plan sans restriction de batterie ? */
    fun isIgnoringBatteryOptimizations(context: Context): Boolean =
        context.getSystemService(PowerManager::class.java).isIgnoringBatteryOptimizations(context.packageName)

    /** Demande système « Autoriser l'appli à toujours fonctionner en arrière-plan ? ». */
    fun requestIgnoreBatteryOptimizations(context: Context): Boolean =
        isIgnoringBatteryOptimizations(context) ||
            start(context, Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, packageUri(context))) ||
            start(context, Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))

    /** Fiche de l'appli dans les réglages Android (économie de batterie, autorisations). */
    fun openAppSettings(context: Context): Boolean =
        start(context, Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri(context)))

    private fun packageUri(context: Context): Uri = Uri.parse("package:${context.packageName}")

    private fun start(context: Context, intent: Intent): Boolean = runCatching {
        if (context !is Activity) intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        true
    }.getOrDefault(false)
}
