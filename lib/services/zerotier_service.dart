import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/utils/constants.dart';

class ZeroTierService {
  static const String _baseUrl = 'https://api.zerotier.com/api/v1';
  static const String _proxyUrlFromEnv = String.fromEnvironment('ZT_PROXY_URL');
  
  Future<List<Device>> getDevices(
      String networkId, String apiToken) async {
    final proxyBaseUrl = _resolveWebProxyBaseUrl();
    final url = kIsWeb
        ? '$proxyBaseUrl/devices/$networkId'
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
      if (kIsWeb) {
        throw Exception(
          '网络请求失败（Web 代理不可用）: $e\n'
          '请先启动代理：dart run bin/proxy_server.dart\n'
          '当前代理地址：$proxyBaseUrl',
        );
      }
      throw Exception('网络请求失败: $e');
    }
  }

  String _resolveWebProxyBaseUrl() {
    if (_proxyUrlFromEnv.isNotEmpty) {
      return _proxyUrlFromEnv;
    }

    final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
    final scheme = Uri.base.scheme == 'https' ? 'https' : 'http';
    return '$scheme://$host:3000/api';
  }
}