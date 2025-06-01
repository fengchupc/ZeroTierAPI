import 'package:zerotierapi/models/device_model.dart';

abstract class ApiService {
  Future<List<Device>> getDevices();
  Future<Device> getDevice(String networkId);
  Future<void> updateDevice(Device device);
} 