package com.assoumou.mifi

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Canal « com.assoumou.mifi/native » d'un moteur Flutter (principal ou
 * d'arrière-plan). Contrat : lib/core/native/native_bridge.dart.
 */
class NativeBridge(
    private val context: Context,
    engine: FlutterEngine,
    private val activity: MainActivity?,
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
    private val mainHandler = Handler(Looper.getMainLooper())

    /** Moteur d'arrière-plan : tâche à exécuter et rappel de fin. */
    var backgroundTask: Pair<String, String>? = null
    var onTaskCompleted: ((Boolean, String?) -> Unit)? = null

    init {
        channel.setMethodCallHandler(this)
    }

    fun detach() = channel.setMethodCallHandler(null)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            handle(call, result)
        } catch (e: Exception) {
            result.error("native_error", e.message, null)
        }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "bindToWifi" -> result.success(WifiBinder.get(context).bind().toMap())
            "getWifiStatus" -> result.success(WifiBinder.get(context).status().toMap())
            "probeInternet" -> {
                val binder = WifiBinder.get(context)
                Thread {
                    val reachable = binder.probeInternet()
                    mainHandler.post { result.success(reachable) }
                }.start()
            }
            "suggestWifiNetwork" -> result.success(
                activity?.suggestWifiNetwork(
                    call.argument<String>("ssid") ?: "",
                    call.argument<String>("password") ?: "",
                    call.argument<Boolean>("hidden") ?: false,
                ) ?: false
            )
            "setKeepScreenOn" -> {
                activity?.setKeepScreenOn(call.argument<Boolean>("on") ?: false)
                result.success(null)
            }
            "ensureNotificationChannels" -> {
                @Suppress("UNCHECKED_CAST")
                val channels = call.argument<List<Map<String, Any?>>>("channels") ?: emptyList()
                Notifications.ensureChannels(context, channels)
                result.success(null)
            }
            "showNotification" -> {
                Notifications.show(
                    context,
                    id = call.argument<Int>("id") ?: 0,
                    channelId = call.argument<String>("channelId") ?: Notifications.FALLBACK_CHANNEL,
                    title = call.argument<String>("title") ?: "",
                    body = call.argument<String>("body") ?: "",
                    route = call.argument<String>("route"),
                    actionLabel = call.argument<String>("actionLabel"),
                    actionRoute = call.argument<String>("actionRoute"),
                )
                result.success(null)
            }
            "requestNotificationPermission" -> {
                val target = activity
                if (target == null) result.success(Notifications.enabled(context))
                else target.requestNotificationPermission { granted -> result.success(granted) }
            }
            "areNotificationsEnabled" -> result.success(Notifications.enabled(context))
            "saveDocument" -> {
                val target = activity
                val bytes = call.argument<ByteArray>("bytes")
                if (target == null || bytes == null) result.success(false)
                else target.saveDocument(
                    call.argument<String>("fileName") ?: "mifi.json",
                    call.argument<String>("mimeType") ?: "application/octet-stream",
                    bytes,
                ) { ok -> result.success(ok) }
            }
            "shareText" -> {
                activity?.shareText(call.argument<String>("text") ?: "", call.argument<String>("title"))
                result.success(null)
            }
            "publishToggleState" -> {
                ToggleStateStore.write(
                    context,
                    toggle = call.argument<String>("toggle") ?: ToggleStateStore.MOBILE_DATA,
                    state = call.argument<String>("state") ?: "unknown",
                    label = call.argument<String>("label"),
                    stateText = call.argument<String>("stateText"),
                    switchingText = call.argument<String>("switchingText"),
                )
                QuickToggles.refresh(context)
                result.success(null)
            }
            "publishStatusWidget" -> {
                StatusWidgetStore.write(context, call.arguments as? Map<*, *> ?: emptyMap<String, Any?>())
                StatusWidgetProvider.updateAll(context)
                result.success(null)
            }
            "setPeriodicCheck" -> {
                TaskScheduler.setPeriodicCheck(
                    context,
                    call.argument<Boolean>("enabled") ?: false,
                    (call.argument<Int>("intervalMinutes") ?: 15).toLong(),
                )
                result.success(null)
            }
            "scheduleTask" -> {
                val task = call.argument<String>("task")
                val at = call.argument<Number>("atMillis")?.toLong()
                if (task != null && at != null) TaskScheduler.scheduleAlarm(context, task, at)
                result.success(null)
            }
            "cancelScheduledTask" -> {
                call.argument<String>("task")?.let { TaskScheduler.cancelAlarm(context, it) }
                result.success(null)
            }
            "getBackgroundTask" -> result.success(
                backgroundTask?.let { mapOf("task" to it.first, "payload" to it.second) }
            )
            "backgroundTaskCompleted" -> {
                result.success(null)
                onTaskCompleted?.invoke(call.argument<Boolean>("success") ?: false, call.argument<String>("message"))
            }
            "takeLaunchRoute" -> result.success(activity?.takeLaunchRoute())
            "startMonitor" -> result.success(MonitorService.start(context))
            "stopMonitor" -> {
                MonitorService.stop(context)
                result.success(null)
            }
            "isMonitorRunning" -> result.success(AppEngineHolder.monitorBridge != null)
            "isAppVisible" -> result.success(AppEngineHolder.isResumed)
            "isIgnoringBatteryOptimizations" -> result.success(SystemSettings.isIgnoringBatteryOptimizations(context))
            "requestIgnoreBatteryOptimizations" ->
                result.success(SystemSettings.requestIgnoreBatteryOptimizations(activity ?: context))
            "canScheduleExactAlarms" -> result.success(SystemSettings.canScheduleExactAlarms(context))
            "openExactAlarmSettings" -> result.success(SystemSettings.openExactAlarmSettings(activity ?: context))
            "openAutostartSettings" -> result.success(SystemSettings.openAutostartSettings(activity ?: context))
            "openAppSettings" -> result.success(SystemSettings.openAppSettings(activity ?: context))
            else -> result.notImplemented()
        }
    }

    /** Demande à l'interface Dart d'ouvrir un écran. */
    fun openRoute(route: String) = mainHandler.post {
        channel.invokeMethod("openRoute", mapOf("route" to route))
    }

    /** Confie une tâche à l'appli ouverte (moteur principal). */
    fun runTask(task: String, payload: String, callback: (Boolean, String?) -> Unit) = mainHandler.post {
        channel.invokeMethod(
            "runTask",
            mapOf("task" to task, "payload" to TaskScheduler.decodePayload(payload)),
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    val map = result as? Map<*, *>
                    callback(map?.get("success") == true, map?.get("message") as? String)
                }

                override fun error(code: String, message: String?, details: Any?) = callback(false, message)
                override fun notImplemented() = callback(false, "not implemented")
            },
        )
    }

    companion object {
        const val CHANNEL = "com.assoumou.mifi/native"
    }
}
