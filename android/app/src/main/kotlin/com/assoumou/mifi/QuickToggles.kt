package com.assoumou.mifi

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.graphics.drawable.Icon
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.os.Build

/** États des interrupteurs rapides publiés par Dart (textes traduits). */
object ToggleStateStore {
    const val MOBILE_DATA = "mobile_data"
    private const val PREFS = "mifi_native"

    data class State(val state: String, val label: String?, val stateText: String?, val switchingText: String?)

    fun write(context: Context, toggle: String, state: String, label: String?, stateText: String?, switchingText: String?) {
        val editor = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString("$toggle.state", state)
            .putString("$toggle.label", label)
            .putString("$toggle.stateText", stateText)
        if (switchingText != null) editor.putString("$toggle.switchingText", switchingText)
        editor.apply()
    }

    fun read(context: Context, toggle: String): State {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return State(
            state = prefs.getString("$toggle.state", "unknown") ?: "unknown",
            label = prefs.getString("$toggle.label", null),
            stateText = prefs.getString("$toggle.stateText", null),
            switchingText = prefs.getString("$toggle.switchingText", null),
        )
    }

    /** Appui sur une tuile : afficher « bascule » tout de suite. */
    fun markSwitching(context: Context, toggle: String) {
        val current = read(context, toggle)
        write(
            context,
            toggle,
            "switching",
            current.label,
            current.switchingText ?: context.getString(R.string.toggle_switching),
            current.switchingText,
        )
    }
}

object QuickToggles {
    /** Lance la bascule d'un interrupteur depuis sa tuile. */
    fun toggle(context: Context, toggle: String) {
        if (ToggleStateStore.read(context, toggle).state == "switching") return
        ToggleStateStore.markSwitching(context, toggle)
        refresh(context)
        TaskScheduler.enqueue(context, "mobile_data_toggle")
    }

    /** Redessine les tuiles. */
    fun refresh(context: Context) {
        runCatching {
            TileService.requestListeningState(context, ComponentName(context, MobileDataTileService::class.java))
        }
    }
}

/** Tuile « Réglages rapides » d'un interrupteur (données mobiles). */
abstract class ToggleTileService : TileService() {
    abstract val toggle: String
    abstract val defaultLabel: Int
    abstract val iconRes: Int

    override fun onStartListening() {
        super.onStartListening()
        render()
    }

    override fun onClick() {
        super.onClick()
        if (isLocked) unlockAndRun { QuickToggles.toggle(this, toggle) } else QuickToggles.toggle(this, toggle)
        render()
    }

    private fun render() {
        val tile = qsTile ?: return
        val state = ToggleStateStore.read(this, toggle)
        tile.label = state.label ?: getString(defaultLabel)
        tile.icon = Icon.createWithResource(this, iconRes)
        tile.state = when (state.state) {
            "on" -> Tile.STATE_ACTIVE
            "switching" -> Tile.STATE_UNAVAILABLE
            else -> Tile.STATE_INACTIVE
        }
        if (Build.VERSION.SDK_INT >= 29) tile.subtitle = state.stateText
        tile.updateTile()
    }
}

class MobileDataTileService : ToggleTileService() {
    override val toggle = ToggleStateStore.MOBILE_DATA
    override val defaultLabel = R.string.tile_mobile_data_label
    override val iconRes = R.drawable.ic_tile_mobile_data
}

/** Raccourci vers la liste des widgets d'un fournisseur. */
fun AppWidgetManager.idsOf(context: Context, provider: Class<*>): IntArray =
    getAppWidgetIds(ComponentName(context, provider))
