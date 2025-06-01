import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService with ChangeNotifier {
  static const String _apiTokenKey = 'zerotier_api_token';
  static const String _networkIdKey = 'zerotier_network_id';
  static const String _timeZoneKey = 'zerotier_time_zone';
  
  String? _apiToken;
  String? _networkId;
  String? _timeZone;
  
  StorageService();
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiToken = prefs.getString(_apiTokenKey);
    _networkId = prefs.getString(_networkIdKey);
    _timeZone = prefs.getString(_timeZoneKey);
    notifyListeners();
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
    final prefs = await SharedPreferences.getInstance();
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