package com.example.zerotierapi

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context

class AllDevicesWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        DeviceStatusWidgetUpdater.updateWidgets(
            context,
            appWidgetManager,
            appWidgetIds,
            DeviceStatusWidgetUpdater.FilterType.ALL,
        )
    }
}
