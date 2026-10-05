package com.assoumou.mifi

import android.content.Context
import android.content.pm.ServiceInfo
import android.os.Build
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkerParameters
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import kotlin.coroutines.resume

/**
 * Exécute une tâche Dart (vérification périodique, données
 * mobiles, redémarrage…) une à la fois :
 * - vérification périodique alors que l'appli est visible ou que la
 *   surveillance continue tourne → rien à faire ;
 * - appli ouverte, ou surveillance continue → tâche confiée à ce moteur
 *   (une seule session avec le modem) ;
 * - sinon → moteur Flutter d'arrière-plan qui exécute `backgroundMain`.
 */
class ModemTaskWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val task = inputData.getString(TaskScheduler.KEY_TASK) ?: return Result.failure()
        val payload = inputData.getString(TaskScheduler.KEY_PAYLOAD) ?: ""
        if (task == "periodic_check" && (AppEngineHolder.isResumed || AppEngineHolder.monitorBridge != null)) {
            return Result.success()
        }
        val ok = taskLock.withLock {
            withTimeoutOrNull(TASK_TIMEOUT_MS) {
                val running = AppEngineHolder.mainBridge ?: AppEngineHolder.monitorBridge
                if (running != null) runOnMainEngine(running, task, payload) else runOnBackgroundEngine(task, payload)
            } ?: false
        }
        // Une tâche manquée sera reprise au prochain déclenchement : pas de nouvel essai.
        return if (ok) Result.success() else Result.failure()
    }

    private suspend fun runOnMainEngine(bridge: NativeBridge, task: String, payload: String): Boolean =
        suspendCancellableCoroutine { cont ->
            bridge.runTask(task, payload) { success, _ -> if (cont.isActive) cont.resume(success) }
        }

    private suspend fun runOnBackgroundEngine(task: String, payload: String): Boolean = withContext(Dispatchers.Main) {
        val context = applicationContext
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(context)
        loader.ensureInitializationComplete(context, null)
        val engine = FlutterEngine(context)
        val bridge = NativeBridge(context, engine, null)
        bridge.backgroundTask = task to payload
        try {
            suspendCancellableCoroutine { cont ->
                bridge.onTaskCompleted = { success, _ -> if (cont.isActive) cont.resume(success) }
                engine.dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "backgroundMain"),
                    listOf(task, payload),
                )
            }
        } finally {
            bridge.detach()
            engine.destroy()
        }
    }

    override suspend fun getForegroundInfo(): ForegroundInfo {
        val notification = Notifications.workNotification(applicationContext)
        return if (Build.VERSION.SDK_INT >= 29) {
            ForegroundInfo(WORK_NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            ForegroundInfo(WORK_NOTIFICATION_ID, notification)
        }
    }

    companion object {
        private const val TASK_TIMEOUT_MS = 9 * 60 * 1000L
        private const val WORK_NOTIFICATION_ID = 4242
        private val taskLock = Mutex()
    }
}
