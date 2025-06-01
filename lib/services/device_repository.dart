import 'package:flutter/foundation.dart';
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/services/zerotier_service.dart';
import 'package:zerotierapi/services/database_helper.dart';
import 'package:zerotierapi/services/web_storage_service.dart';

class DeviceRepository {
  final ZeroTierService apiService;
  final dynamic storage;
  
  DeviceRepository({
    required this.apiService,
    required this.storage,
  });

  Future<List<Device>> getDevices(String networkId, String apiToken) async {
    try {
      // 尝试从网络获取最新数据
      final onlineDevices = await apiService.getDevices(networkId, apiToken);
      
      // 保存到存储
      if (kIsWeb) {
        await (storage as WebStorageService).saveDevices(onlineDevices);
      } else {
        await (storage as DatabaseHelper).batchInsertDevices(onlineDevices);
      }
      
      return onlineDevices;
    } catch (e) {
      // 网络请求失败时，从本地存储获取缓存数据
      final List<Device> cachedDevices;
      if (kIsWeb) {
        cachedDevices = await (storage as WebStorageService).getDevices();
      } else {
        cachedDevices = await (storage as DatabaseHelper).getAllDevices();
      }
      
      if (cachedDevices.isEmpty) {
        throw Exception('无法获取设备数据，且本地无缓存');
      }
      
      return cachedDevices;
    }
  }
} 