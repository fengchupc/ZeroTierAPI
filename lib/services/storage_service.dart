import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerotierapi/services/storage_interface.dart';

class StorageService extends ChangeNotifier implements StorageInterface {
  static const String _apiTokenKey = 'zerotier_api_token';
  static const String _networkIdKey = 'zerotier_network_id';
  static const String _timeZoneKey = 'zerotier_time_zone';
  
  String? _apiToken;
  String? _networkId;
  String? _timeZone;
  SharedPreferences? _prefs;
  bool _initialized = false;
  
  StorageService();
  
  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _apiToken = _prefs?.getString(_apiTokenKey);
    _networkId = _prefs?.getString(_networkIdKey);
    _timeZone = _prefs?.getString(_timeZoneKey);
    _initialized = true;
    notifyListeners();
  }
  
  Future<SharedPreferences> get _preferences async {
    if (!_initialized) {
      await initialize();
    }
    return _prefs!;
  }
  
  @override
  Future<String?> getApiToken() async {
    final prefs = await _preferences;
    return prefs.getString(_apiTokenKey);
  }
  
  @override
  Future<void> setApiToken(String token) async {
    final prefs = await _preferences;
    await prefs.setString(_apiTokenKey, token);
    _apiToken = token;
    notifyListeners();
  }
  
  @override
  Future<void> clearApiToken() async {
    final prefs = await _preferences;
    await prefs.remove(_apiTokenKey);
    _apiToken = null;
    notifyListeners();
  }
  
  @override
  Future<Map<String, dynamic>?> getDeviceCache(String networkId) async {
    // 实现设备缓存获取
    return null;
  }
  
  @override
  Future<void> setDeviceCache(String networkId, Map<String, dynamic> data) async {
    // 实现设备缓存存储
  }
  
  @override
  Future<void> clearCache() async {
    // 实现缓存清理
  }
  
  String? get apiToken => _apiToken;
  String? get networkId => _networkId;
  String? get timeZone => _timeZone;
  
  set apiToken(String? value) {
    _apiToken = value;
    _saveString(_apiTokenKey, value);
    notifyListeners();
  }
  
  set networkId(String? value) {
    _networkId = value;
    _saveString(_networkIdKey, value);
    notifyListeners();
  }
  
  set timeZone(String? value) {
    _timeZone = value;
    _saveString(_timeZoneKey, value);
    notifyListeners();
  }
  
  Future<void> _saveString(String key, String? value) async {
    final prefs = await _preferences;
    if (value != null) {
      await prefs.setString(key, value);
    } else {
      await prefs.remove(key);
    }
  }
  
  bool get isConfigured {
    return _apiToken != null && 
           _apiToken!.isNotEmpty && 
           _networkId != null && 
           _networkId!.isNotEmpty;
  }
}