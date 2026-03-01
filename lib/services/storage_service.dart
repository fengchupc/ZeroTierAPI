import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService with ChangeNotifier {
  static const String _apiTokenKey = 'zerotier_api_token';
  static const String _networkIdKey = 'zerotier_network_id';
  static const String _timeZoneKey = 'zerotier_time_zone';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool? _secureStorageAvailable;
  
  String? _apiToken;
  String? _networkId;
  String? _timeZone;
  
  StorageService();
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiToken = await _readSecureValueWithMigration(
      key: _apiTokenKey,
      legacyPrefs: prefs,
    );
    _networkId = await _readSecureValueWithMigration(
      key: _networkIdKey,
      legacyPrefs: prefs,
    );
    _timeZone = prefs.getString(_timeZoneKey);
    notifyListeners();
  }
  
  String? get apiToken => _apiToken;
  String? get networkId => _networkId;
  String? get timeZone => _timeZone;
  
  set apiToken(String? value) {
    _apiToken = value;
    _saveSecureString(_apiTokenKey, value);
    notifyListeners();
  }
  
  set networkId(String? value) {
    _networkId = value;
    _saveSecureString(_networkIdKey, value);
    notifyListeners();
  }
  
  set timeZone(String? value) {
    _timeZone = value;
    _saveString(_timeZoneKey, value);
    notifyListeners();
  }
  
  Future<void> _saveSecureString(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (await _isSecureStorageAvailable()) {
      try {
        if (value != null && value.isNotEmpty) {
          await _secureStorage.write(key: key, value: value);
        } else {
          await _secureStorage.delete(key: key);
        }
        await prefs.remove(key);
        return;
      } on MissingPluginException {
        _secureStorageAvailable = false;
      } on PlatformException {
        _secureStorageAvailable = false;
      }
    }

    if (value != null && value.isNotEmpty) {
      await prefs.setString(key, value);
    } else {
      await prefs.remove(key);
    }
  }

  Future<String?> _readSecureValueWithMigration({
    required String key,
    required SharedPreferences legacyPrefs,
  }) async {
    if (await _isSecureStorageAvailable()) {
      try {
        final secureValue = await _secureStorage.read(key: key);
        if (secureValue != null && secureValue.isNotEmpty) {
          return secureValue;
        }

        final legacyValue = legacyPrefs.getString(key);
        if (legacyValue != null && legacyValue.isNotEmpty) {
          await _secureStorage.write(key: key, value: legacyValue);
          await legacyPrefs.remove(key);
          return legacyValue;
        }
      } on MissingPluginException {
        _secureStorageAvailable = false;
      } on PlatformException {
        _secureStorageAvailable = false;
      }
    }

    return legacyPrefs.getString(key);
  }

  Future<bool> _isSecureStorageAvailable() async {
    if (_secureStorageAvailable != null) {
      return _secureStorageAvailable!;
    }

    try {
      await _secureStorage.containsKey(key: '__secure_storage_probe__');
      _secureStorageAvailable = true;
    } on MissingPluginException {
      _secureStorageAvailable = false;
    } on PlatformException {
      _secureStorageAvailable = false;
    }

    return _secureStorageAvailable!;
  }

  Future<void> _saveString(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null && value.isNotEmpty) {
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