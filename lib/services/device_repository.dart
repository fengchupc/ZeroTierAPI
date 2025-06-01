import 'package:flutter/foundation.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/services/zerotier_service.dart';
import 'package:zerotierapi/services/database_helper.dart';
import 'package:zerotierapi/services/web_storage_service.dart';
import 'package:zerotierapi/services/api_service.dart';
import 'package:zerotierapi/services/storage_interface.dart';

class DeviceRepository {
  final ApiService _apiService;
  final StorageInterface _storage;
  static const int _cacheExpirationMinutes = 5;

  DeviceRepository({
    required ApiService apiService,
    required StorageInterface storage,
  })  : _apiService = apiService,
        _storage = storage;

  Future<List<Device>> getDevices() async {
    try {
      final devices = await _apiService.getDevices();
      for (var device in devices) {
        await _storage.setDeviceCache(
          device.networkId,
          device.toJson(),
        );
      }
      return devices;
    } catch (e) {
      // 如果API请求失败，尝试从缓存获取
      final cachedDevices = await _getCachedDevices();
      if (cachedDevices.isNotEmpty) {
        return cachedDevices;
      }
      rethrow;
    }
  }

  Future<Device> getDevice(String networkId) async {
    try {
      final device = await _apiService.getDevice(networkId);
      await _storage.setDeviceCache(
        networkId,
        device.toJson(),
      );
      return device;
    } catch (e) {
      // 如果API请求失败，尝试从缓存获取
      final cachedDevice = await _getCachedDevice(networkId);
      if (cachedDevice != null) {
        return cachedDevice;
      }
      rethrow;
    }
  }

  Future<void> updateDevice(Device device) async {
    await _apiService.updateDevice(device);
    await _storage.setDeviceCache(
      device.networkId,
      device.toJson(),
    );
  }

  Future<List<Device>> _getCachedDevices() async {
    final devices = <Device>[];
    // 实现从缓存获取设备列表的逻辑
    return devices;
  }

  Future<Device?> _getCachedDevice(String networkId) async {
    final cachedData = await _storage.getDeviceCache(networkId);
    if (cachedData != null) {
      return Device.fromJson(cachedData);
    }
    return null;
  }

  Future<void> clearCache() async {
    await _storage.clearCache();
  }
} 