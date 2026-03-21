import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zerotierapi/models/device_model.dart';
import 'package:zerotierapi/models/network_model.dart';
import 'package:zerotierapi/models/user_model.dart';
import 'package:zerotierapi/utils/constants.dart';

class ZeroTierService {
  static const String _baseUrl = 'https://api.zerotier.com/api/v1';
  static const String _proxyUrlFromEnv = String.fromEnvironment('ZT_PROXY_URL');
  
  Future<List<Device>> getDevices(String networkId, String apiToken) async {
    final body = await _requestJsonList(
      path: 'network/$networkId/member',
      apiToken: apiToken,
    );
    return body.map((dynamic item) => Device.fromJson(item)).toList();
  }

  Future<Device> getDevice(
    String networkId,
    String memberId,
    String apiToken,
  ) async {
    final normalizedMemberId = _normalizeMemberId(networkId, memberId);
    final body = await _requestJsonObject(
      path: 'network/$networkId/member/$normalizedMemberId',
      apiToken: apiToken,
    );
    return Device.fromJson(body);
  }

  Future<Device> updateDevice(
    String networkId,
    String memberId,
    String apiToken,
    Device device,
  ) async {
    final normalizedMemberId = _normalizeMemberId(networkId, memberId);
    final body = await _requestJsonObject(
      path: 'network/$networkId/member/$normalizedMemberId',
      apiToken: apiToken,
      method: 'POST',
      body: device.toMemberUpdateJson(),
    );
    return Device.fromJson(body);
  }

  Future<void> deleteDevice(
    String networkId,
    String memberId,
    String apiToken,
  ) async {
    final normalizedMemberId = _normalizeMemberId(networkId, memberId);
    await _request(
      path: 'network/$networkId/member/$normalizedMemberId',
      apiToken: apiToken,
      method: 'DELETE',
    );
  }

  String _normalizeMemberId(String networkId, String memberId) {
    final trimmedMemberId = memberId.trim();
    final trimmedNetworkId = networkId.trim();

    if (trimmedMemberId.startsWith('${trimmedNetworkId}-')) {
      return trimmedMemberId.substring(trimmedNetworkId.length + 1);
    }

    if (trimmedMemberId.startsWith('${trimmedNetworkId}_')) {
      return trimmedMemberId.substring(trimmedNetworkId.length + 1);
    }

    return trimmedMemberId;
  }

  Future<ZeroTierNetwork> getNetwork(String networkId, String apiToken) async {
    final body = await _requestJsonObject(
      path: 'network/$networkId',
      apiToken: apiToken,
    );
    return ZeroTierNetwork.fromJson(body);
  }

  Future<List<ZeroTierNetwork>> getNetworks(String apiToken) async {
    final body = await _requestJsonList(path: 'network', apiToken: apiToken);
    return body
        .map((dynamic item) => ZeroTierNetwork.fromJson(item))
        .toList();
  }

  Future<ZeroTierNetwork> updateNetwork(
    String networkId,
    String apiToken,
    ZeroTierNetwork network,
  ) async {
    final body = await _requestJsonObject(
      path: 'network/$networkId',
      apiToken: apiToken,
      method: 'POST',
      body: network.toUpdateJson(),
    );
    return ZeroTierNetwork.fromJson(body);
  }

  Future<ZeroTierNetwork> createNetwork(
    String apiToken, {
    String? name,
    String? description,
    bool isPrivate = true,
  }) async {
    final createdBody = await _requestJsonObject(
      path: 'network',
      apiToken: apiToken,
      method: 'POST',
      body: const <String, dynamic>{},
    );
    var network = ZeroTierNetwork.fromJson(createdBody);

    if ((name != null && name.trim().isNotEmpty) ||
        (description != null && description.trim().isNotEmpty) ||
        !isPrivate) {
      network = network.copyWith(
        name: name?.trim().isEmpty == true ? null : name?.trim(),
        description:
            description?.trim().isEmpty == true ? null : description?.trim(),
        isPrivate: isPrivate,
      );
      return updateNetwork(network.id, apiToken, network);
    }

    return network;
  }

  Future<ZeroTierStatus> getStatus(String apiToken) async {
    final body = await _requestJsonObject(path: 'status', apiToken: apiToken);
    return ZeroTierStatus.fromJson(body);
  }

  Future<ZeroTierUser> getUser(String userId, String apiToken) async {
    final body = await _requestJsonObject(
      path: 'user/$userId',
      apiToken: apiToken,
    );
    return ZeroTierUser.fromJson(body);
  }

  Future<ZeroTierUser> updateUser(
    String userId,
    String apiToken,
    ZeroTierUser user,
  ) async {
    final body = await _requestJsonObject(
      path: 'user/$userId',
      apiToken: apiToken,
      method: 'POST',
      body: user.toUpdateJson(),
    );
    return ZeroTierUser.fromJson(body);
  }

  Future<void> deleteUser(String userId, String apiToken) async {
    await _request(
      path: 'user/$userId',
      apiToken: apiToken,
      method: 'DELETE',
    );
  }

  Future<void> addApiToken(
    String userId,
    String apiToken,
    String tokenName,
    String token,
  ) async {
    await _request(
      path: 'user/$userId/token',
      apiToken: apiToken,
      method: 'POST',
      body: {
        'tokenName': tokenName,
        'token': token,
      },
    );
  }

  Future<void> deleteApiToken(
    String userId,
    String apiToken,
    String tokenName,
  ) async {
    await _request(
      path: 'user/$userId/token/$tokenName',
      apiToken: apiToken,
      method: 'DELETE',
    );
  }

  Future<GeneratedApiToken> getRandomToken(String apiToken) async {
    final body = await _requestJsonObject(
      path: 'randomToken',
      apiToken: apiToken,
    );
    return GeneratedApiToken.fromJson(body);
  }

  String _resolveWebProxyBaseUrl() {
    if (_proxyUrlFromEnv.isNotEmpty) {
      return _proxyUrlFromEnv;
    }

    final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
    final scheme = Uri.base.scheme == 'https' ? 'https' : 'http';
    return '$scheme://$host:3000/api';
  }

  Uri _buildUri(String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final baseUrl = kIsWeb ? _resolveWebProxyBaseUrl() : _baseUrl;
    return Uri.parse('$baseUrl/$normalizedPath');
  }

  Future<dynamic> _request({
    required String path,
    required String apiToken,
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final proxyBaseUrl = _resolveWebProxyBaseUrl();

    try {
      final uri = _buildUri(path);
      final headers = <String, String>{
        'Authorization': 'token $apiToken',
        'Content-Type': 'application/json',
      };

      late http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http
              .post(
                uri,
                headers: headers,
                body: json.encode(body ?? const <String, dynamic>{}),
              )
              .timeout(const Duration(seconds: Constants.apiTimeout));
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: Constants.apiTimeout));
          break;
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: Constants.apiTimeout));
          break;
        default:
          throw Exception('不支持的请求方法: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return null;
        }
        return json.decode(response.body);
      }

      final message = _extractErrorMessage(response.body, response.statusCode);
      throw Exception('$message [URL: $uri]');
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

  Future<Map<String, dynamic>> _requestJsonObject({
    required String path,
    required String apiToken,
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final response = await _request(
      path: path,
      apiToken: apiToken,
      method: method,
      body: body,
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<List<dynamic>> _requestJsonList({
    required String path,
    required String apiToken,
  }) async {
    final response = await _request(path: path, apiToken: apiToken);
    return List<dynamic>.from(response as List);
  }

  String _extractErrorMessage(String body, int statusCode) {
    if (body.isEmpty) {
      return 'API请求失败: HTTP $statusCode';
    }

    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message != null && message.toString().isNotEmpty) {
          return 'API请求失败: HTTP $statusCode - $message';
        }
      }
    } catch (_) {
      // Ignore parse failures and fall back to raw body.
    }

    return 'API请求失败: HTTP $statusCode - $body';
  }
}