package com.example.zerotierapi

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject

object DeviceStatusWidgetUpdater {
    private const val PREF_NAME = "zerotier_widget_snapshot"
    private const val SNAPSHOT_KEY = "device_snapshot"

    enum class FilterType {
        ONLINE,
        OFFLINE,
        ALL,
    }

    fun updateAllWidgets(context: Context) {
        val manager = AppWidgetManager.getInstance(context)

        val onlineIds = manager.getAppWidgetIds(
            ComponentName(context, OnlineDevicesWidgetProvider::class.java)
        )
        updateWidgets(context, manager, onlineIds, FilterType.ONLINE)

        val offlineIds = manager.getAppWidgetIds(
            ComponentName(context, OfflineDevicesWidgetProvider::class.java)
        )
        updateWidgets(context, manager, offlineIds, FilterType.OFFLINE)

        val allIds = manager.getAppWidgetIds(
            ComponentName(context, AllDevicesWidgetProvider::class.java)
        )
        updateWidgets(context, manager, allIds, FilterType.ALL)
    }

    fun updateWidgets(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        filterType: FilterType,
    ) {
        if (appWidgetIds.isEmpty()) return

        val snapshot = loadSnapshot(context)
        val devices = snapshot?.optJSONArray("devices") ?: JSONArray()
        val updatedAt = snapshot?.optString("updatedAt").orEmpty()

        val filteredNames = mutableListOf<String>()
        var totalCount = 0

        for (i in 0 until devices.length()) {
            val item = devices.optJSONObject(i) ?: continue
            val online = item.optBoolean("online", false)
            val include = when (filterType) {
                FilterType.ONLINE -> online
                FilterType.OFFLINE -> !online
                FilterType.ALL -> true
            }
            if (!include) continue

            totalCount += 1
            if (filteredNames.size < 4) {
                val name = item.optString("name").ifBlank { item.optString("id", "未知设备") }
                filteredNames += name
            }
        }

        val title = when (filterType) {
            FilterType.ONLINE -> context.getString(R.string.widget_title_online)
            FilterType.OFFLINE -> context.getString(R.string.widget_title_offline)
            FilterType.ALL -> context.getString(R.string.widget_title_all)
        }

        val listText = if (filteredNames.isEmpty()) {
            context.getString(R.string.widget_empty)
        } else {
            filteredNames.joinToString(separator = "\n")
        }

        val updateText = if (updatedAt.isBlank()) {
            context.getString(R.string.widget_updated_unknown)
        } else {
            context.getString(R.string.widget_updated_prefix, updatedAt)
        }

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_device_status)
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_count, totalCount.toString())
            views.setTextViewText(R.id.widget_list, listText)
            views.setTextViewText(R.id.widget_updated_at, updateText)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun loadSnapshot(context: Context): JSONObject? {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(SNAPSHOT_KEY, null) ?: return null
        return try {
            JSONObject(raw)
        } catch (_: Throwable) {
            null
        }
    }

    fun saveSnapshot(context: Context, payload: JSONObject) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(SNAPSHOT_KEY, payload.toString()).apply()
    }
}
