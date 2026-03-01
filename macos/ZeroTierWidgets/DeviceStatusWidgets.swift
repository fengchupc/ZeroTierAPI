import WidgetKit
import SwiftUI

private let appGroupIdentifier = "group.com.example.zerotierapi.widgets"
private let snapshotKey = "device_snapshot"

private enum DeviceFilter {
  case online
  case offline
  case all

  var kind: String {
    switch self {
    case .online:
      return "com.example.zerotierapi.widgets.online"
    case .offline:
      return "com.example.zerotierapi.widgets.offline"
    case .all:
      return "com.example.zerotierapi.widgets.all"
    }
  }

  var title: String {
    switch self {
    case .online:
      return "在线设备"
    case .offline:
      return "离线设备"
    case .all:
      return "全部设备"
    }
  }
}

private struct DeviceItem: Decodable {
  let id: String
  let name: String?
  let online: Bool
}

private struct SnapshotPayload: Decodable {
  let updatedAt: String?
  let devices: [DeviceItem]
}

private struct DeviceStatusEntry: TimelineEntry {
  let date: Date
  let title: String
  let devices: [DeviceItem]
  let count: Int
  let updatedAtText: String
}

private struct DeviceStatusProvider: TimelineProvider {
  let filter: DeviceFilter

  func placeholder(in context: Context) -> DeviceStatusEntry {
    DeviceStatusEntry(
      date: Date(),
      title: filter.title,
      devices: [
        DeviceItem(id: "placeholder-1", name: "示例设备 A", online: true),
        DeviceItem(id: "placeholder-2", name: "示例设备 B", online: false)
      ],
      count: 2,
      updatedAtText: "刚刚"
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (DeviceStatusEntry) -> Void) {
    completion(makeEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<DeviceStatusEntry>) -> Void) {
    let entry = makeEntry()
    let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
    completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
  }

  private func makeEntry() -> DeviceStatusEntry {
    let snapshot = loadSnapshot()
    let filtered = filterDevices(snapshot.devices)
    let updatedText = formatUpdatedAt(snapshot.updatedAt)

    return DeviceStatusEntry(
      date: Date(),
      title: filter.title,
      devices: Array(filtered.prefix(4)),
      count: filtered.count,
      updatedAtText: updatedText
    )
  }

  private func loadSnapshot() -> SnapshotPayload {
    guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
          let raw = defaults.data(forKey: snapshotKey),
          let payload = try? JSONDecoder().decode(SnapshotPayload.self, from: raw) else {
      return SnapshotPayload(updatedAt: nil, devices: [])
    }
    return payload
  }

  private func filterDevices(_ devices: [DeviceItem]) -> [DeviceItem] {
    switch filter {
    case .online:
      return devices.filter { $0.online }
    case .offline:
      return devices.filter { !$0.online }
    case .all:
      return devices
    }
  }

  private func formatUpdatedAt(_ value: String?) -> String {
    guard let value,
          let date = ISO8601DateFormatter().date(from: value) else {
      return "未知"
    }

    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    return formatter.localizedString(for: date, relativeTo: Date())
  }
}

private struct DeviceStatusWidgetView: View {
  let entry: DeviceStatusProvider.Entry

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(entry.title)
          .font(.headline)
        Spacer()
        Text("\(entry.count)")
          .font(.headline)
          .bold()
      }

      if entry.devices.isEmpty {
        Text("暂无设备")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      } else {
        ForEach(entry.devices, id: \.id) { device in
          Text(device.name ?? device.id)
            .font(.caption)
            .lineLimit(1)
        }
      }

      Spacer(minLength: 0)

      Text("更新: \(entry.updatedAtText)")
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .padding()
  }
}

struct OnlineDevicesWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: DeviceFilter.online.kind,
      provider: DeviceStatusProvider(filter: .online)
    ) { entry in
      DeviceStatusWidgetView(entry: entry)
    }
    .configurationDisplayName("在线设备")
    .description("显示当前在线设备数量和列表")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct OfflineDevicesWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: DeviceFilter.offline.kind,
      provider: DeviceStatusProvider(filter: .offline)
    ) { entry in
      DeviceStatusWidgetView(entry: entry)
    }
    .configurationDisplayName("离线设备")
    .description("显示当前离线设备数量和列表")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct AllDevicesWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: DeviceFilter.all.kind,
      provider: DeviceStatusProvider(filter: .all)
    ) { entry in
      DeviceStatusWidgetView(entry: entry)
    }
    .configurationDisplayName("全部设备")
    .description("显示全部设备数量和列表")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
