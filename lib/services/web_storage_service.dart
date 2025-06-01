import 'dart:convert';
import 'dart:html' as html;
import 'package:zerotierapi/services/storage_interface.dart';

class WebStorageService implements StorageInterface {
  static const String _tokenKey = 'zerotier_api_token';
  static const String _cachePrefix = 'zerotier_cache_';
  final html.Storage _localStorage = html.window.localStorage;

  @override
  Future<void> initialize() async {
    // Web storage doesn't need initialization
  }

  @override
  Future<String?> getApiToken() async {
    return _localStorage[_tokenKey];
  }

  @override
  Future<void> setApiToken(String token) async {
    _localStorage[_tokenKey] = token;
  }

  @override
  Future<void> clearApiToken() async {
    _localStorage.remove(_tokenKey);
  }

  @override
  Future<Map<String, dynamic>?> getDeviceCache(String networkId) async {
    final data = _localStorage['$_cachePrefix$networkId'];
    if (data == null) return null;
    return json.decode(data) as Map<String, dynamic>;
  }

  @override
  Future<void> setDeviceCache(String networkId, Map<String, dynamic> data) async {
    _localStorage['$_cachePrefix$networkId'] = json.encode(data);
  }

  @override
  Future<void> clearCache() async {
    final keysToRemove = _localStorage.keys
        .where((key) => key.startsWith(_cachePrefix))
        .toList();
    
    for (final key in keysToRemove) {
      _localStorage.remove(key);
    }
  }
} 