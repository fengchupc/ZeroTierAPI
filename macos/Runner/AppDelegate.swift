import Cocoa
import FlutterMacOS
#if canImport(WidgetKit)
import WidgetKit
#endif

@main
class AppDelegate: FlutterAppDelegate {
  private let widgetChannelName = "zerotierapi/widget_sync"
  private let widgetAppGroup = "group.com.example.zerotierapi.widgets"
  private let widgetDataKey = "device_snapshot"

  override func applicationDidFinishLaunching(_ notification: Notification) {
    guard let flutterViewController = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      super.applicationDidFinishLaunching(notification)
      return
    }

    let channel = FlutterMethodChannel(
      name: widgetChannelName,
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(code: "unavailable", message: "AppDelegate released", details: nil))
        return
      }

      switch call.method {
      case "syncDeviceSnapshot":
        self.handleSyncSnapshot(call.arguments, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.applicationDidFinishLaunching(notification)
  }

  private func handleSyncSnapshot(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let payload = arguments as? [String: Any] else {
      result(FlutterError(code: "invalid_args", message: "Expected map payload", details: nil))
      return
    }

    do {
      let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
      guard let defaults = UserDefaults(suiteName: widgetAppGroup) else {
        result(FlutterError(code: "app_group", message: "App Group is not configured", details: widgetAppGroup))
        return
      }

      defaults.set(jsonData, forKey: widgetDataKey)
      defaults.synchronize()

      #if canImport(WidgetKit)
      if #available(macOS 11.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
      #endif

      result(nil)
    } catch {
      result(FlutterError(code: "serialize_error", message: "Failed to serialize widget payload", details: error.localizedDescription))
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
