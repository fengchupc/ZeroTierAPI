import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/utils/constants.dart';

class ZeroTierService {
  static const String _baseUrl = 'https://api.zerotier.com/api/v1';
  static const String _proxyUrl = 'http://localhost:3000/api';  // 本地代理服务器
  
  Future<List<Device>> getDevices(
      String networkId, String apiToken) async {
    final url = kIsWeb
        ? '$_proxyUrl/devices/$networkId'
        : '$_baseUrl/network/$networkId/member';
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: Constants.apiTimeout));

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => Device.fromJson(item)).toList();
      } else {
        throw Exception('API请求失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('网络请求失败: $e');
    }
  }
}