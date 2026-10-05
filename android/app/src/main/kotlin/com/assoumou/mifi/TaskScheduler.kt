package com.assoumou.mifi

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf
import org.json.JSONObject
import java.util.concurrent.TimeUnit

/** Mise en file des tâches Dart (WorkManager) et alarmes (AlarmManager). */
object TaskScheduler {
    const val KEY_TASK = "task"
    const val KEY_PAYLOAD = "payload"
    private const val PERIODIC_CHECK = "periodic_check"

    /** Lance la tâche dès que possible (travail accéléré). */
    fun enqueue(context: Context, task: String, payload: String = "", replace: Boolean = false) {
        val request = OneTimeWorkRequestBuilder<ModemTaskWorker>()
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .setInputData(workDataOf(KEY_TASK to task, KEY_PAYLOAD to payload))
            .build()
        WorkManager.getInstance(context).enqueueUniqueWork(
            "task_$task",
            if (replace) ExistingWorkPolicy.REPLACE else ExistingWorkPolicy.KEEP,
            request,
        )
    }

    fun setPeriodicCheck(context: Context, enabled: Boolean, intervalMinutes: Long) {
        val manager = WorkManager.getInstance(context)
        if (!enabled) {
            manager.cancelUniqueWork(PERIODIC_CHECK)
            return
        }
        val request = PeriodicWorkRequestBuilder<ModemTaskWorker>(intervalMinutes.coerceAtLeast(15), TimeUnit.MINUTES)
            .setInputData(workDataOf(KEY_TASK to PERIODIC_CHECK, KEY_PAYLOAD to ""))
            .build()
        manager.enqueueUniquePeriodicWork(PERIODIC_CHECK, ExistingPeriodicWorkPolicy.UPDATE, request)
    }

    fun scheduleAlarm(context: Context, task: String, atMillis: Long) {
        val alarms = context.getSystemService(AlarmManager::class.java)
        val pending = alarmIntent(context, task)
        val exact = Build.VERSION.SDK_INT < 31 || alarms.canScheduleExactAlarms()
        if (exact) {
            alarms.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pending)
        } else {
            alarms.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, atMillis, pending)
        }
    }

    fun cancelAlarm(context: Context, task: String) {
        context.getSystemService(AlarmManager::class.java).cancel(alarmIntent(context, task))
    }

    private fun alarmIntent(context: Context, task: String): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java)
            .setAction(AlarmReceiver.ACTION)
            .putExtra(KEY_TASK, task)
        return PendingIntent.getBroadcast(
            context,
            task.hashCode(),
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    /** Charge JSON d'une tâche → Map pour Dart. */
    fun decodePayload(payload: String): Map<String, Any?> {
        if (payload.isBlank()) return emptyMap()
        return runCatching {
            val json = JSONObject(payload)
            json.keys().asSequence().associateWith { key -> json.opt(key).takeUnless { it == JSONObject.NULL } }
        }.getOrDefault(emptyMap())
    }
}

/** Alarme du redémarrage programmé. */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val task = intent.getStringExtra(TaskScheduler.KEY_TASK) ?: return
        TaskScheduler.enqueue(context, task, replace = true)
    }

    companion object {
        const val ACTION = "com.assoumou.mifi.ALARM"
    }
}

/** Après un redémarrage du téléphone ou une mise à jour : reprogrammer. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> {
                TaskScheduler.enqueue(context, "reschedule", replace = true)
                // Après une mise à jour, le widget reprend son affichage actuel.
                StatusWidgetProvider.updateAll(context)
                // Surveillance continue voulue par l'utilisateur : la relancer.
                MonitorService.resume(context)
            }
        }
    }
}
