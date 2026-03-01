package com.example.zerotierapi

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
	private val widgetChannelName = "zerotierapi/widget_sync"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			widgetChannelName,
		).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
			when (call.method) {
				"syncDeviceSnapshot" -> {
					handleSyncSnapshot(call.arguments, result)
				}

				else -> result.notImplemented()
			}
		}
	}

	private fun handleSyncSnapshot(arguments: Any?, result: MethodChannel.Result) {
		val map = arguments as? Map<*, *> ?: run {
			result.error("invalid_args", "Expected map payload", null)
			return
		}

		try {
			val payload = JSONObject(map)
			DeviceStatusWidgetUpdater.saveSnapshot(applicationContext, payload)
			DeviceStatusWidgetUpdater.updateAllWidgets(applicationContext)
			result.success(null)
		} catch (e: Throwable) {
			result.error("serialize_error", "Failed to serialize widget payload", e.message)
		}
	}
}
