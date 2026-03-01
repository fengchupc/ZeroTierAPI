import WidgetKit
import SwiftUI

@main
struct DeviceStatusWidgetsBundle: WidgetBundle {
  var body: some Widget {
    OnlineDevicesWidget()
    OfflineDevicesWidget()
    AllDevicesWidget()
  }
}
