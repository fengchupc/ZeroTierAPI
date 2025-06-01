import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerotierapi/models/device_model.dart';

class WebStorageService {
  static const String _devicesKey = 'devices';
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveDevices(List<Device> devices) async {
    final devicesList = devices.map((device) => jsonEncode(device.toMap())).toList();
    await _prefs.setStringList(_devicesKey, devicesList);
  }

  Future<List<Device>> getDevices() async {
    final devicesList = _prefs.getStringList(_devicesKey) ?? [];
    return devicesList
        .map((deviceJson) => Device.fromMap(jsonDecode(deviceJson)))
        .toList();
  }

  Future<void> clearDevices() async {
    await _prefs.remove(_devicesKey);
  }

  Future<DateTime> getLastUpdateTime() async {
    final devices = await getDevices();
    if (devices.isEmpty) {
      return DateTime(1970);
    }
    
    int? lastOnline = devices.first.lastOnline;
    for (var device in devices) {
      if (device.lastOnline != null && (lastOnline == null || device.lastOnline! > lastOnline)) {
        lastOnline = device.lastOnline;
      }
    }
    
    return DateTime.fromMillisecondsSinceEpoch(lastOnline ?? 0);
  }
} 