abstract class StorageInterface {
  Future<void> initialize();
  Future<String?> getApiToken();
  Future<void> setApiToken(String token);
  Future<void> clearApiToken();
  Future<Map<String, dynamic>?> getDeviceCache(String networkId);
  Future<void> setDeviceCache(String networkId, Map<String, dynamic> data);
  Future<void> clearCache();
} 