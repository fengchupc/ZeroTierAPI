import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/services/api_service.dart';
import 'package:zerotierapi/services/storage_service.dart';

class ZeroTierService implements ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';
  final StorageService _storageService;

  ZeroTierService(this._storageService);

  Future<Map<String, String>> get _headers async {
    final token = await _storageService.getApiToken();
    if (token == null || token.isEmpty) {
      throw Exception('请先在设置中配置 API Token');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<Device>> getDevices() async {
    try {
      final headers = await _headers;
      final networkId = _storageService.networkId;
      if (networkId == null || networkId.isEmpty) {
        throw Exception('请先在设置中配置 Network ID');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/devices/$networkId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception('获取设备列表失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取设备列表错误: $e');
    }
  }

  @override
  Future<Device> getDevice(String networkId) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/devices/$networkId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Device.fromJson(json.decode(response.body));
      } else {
        throw Exception('获取设备详情失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取设备详情错误: $e');
    }
  }

  @override
  Future<void> updateDevice(Device device) async {
    try {
      final headers = await _headers;
      final response = await http.put(
        Uri.parse('$_baseUrl/devices/${device.networkId}'),
        headers: headers,
        body: json.encode(device.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('更新设备失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('更新设备错误: $e');
    }
  }
}