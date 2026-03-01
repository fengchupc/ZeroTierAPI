import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:zerotierapi/models/device_model.dart';

class WidgetSyncService {
  static const MethodChannel _channel = MethodChannel('zerotierapi/widget_sync');

  Future<void> syncDevices(List<Device> devices) async {
    if (kIsWeb) {
      return;
    }

    final payload = {
      'updatedAt': DateTime.now().toIso8601String(),
      'devices': devices.map(_toPayload).toList(growable: false),
    };

    try {
      await _channel.invokeMethod<void>('syncDeviceSnapshot', payload);
    } on MissingPluginException {
      // Native widget bridge is unavailable on this platform/build.
    } on PlatformException {
      // Ignore widget sync failures to avoid affecting the main flow.
    }
  }

  Map<String, dynamic> _toPayload(Device device) {
    return {
      'id': device.id,
      'name': (device.name == null || device.name!.trim().isEmpty)
          ? device.id
          : device.name,
      'online': device.online,
      'lastOnline': device.lastOnline,
      'ipAddress': device.ipAddress,
    };
  }
}
