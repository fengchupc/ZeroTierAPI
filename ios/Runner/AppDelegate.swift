import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let widgetChannelName = "zerotierapi/widget_sync"
  private let widgetAppGroup = "group.com.example.zerotierapi.widgets"
  private let widgetDataKey = "device_snapshot"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let flutterViewController = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: widgetChannelName,
        binaryMessenger: flutterViewController.binaryMessenger
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
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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

      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }

      result(nil)
    } catch {
      result(FlutterError(code: "serialize_error", message: "Failed to serialize widget payload", details: error.localizedDescription))
    }
  }
}
