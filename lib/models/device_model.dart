import 'package:zerotierapi/utils/constants.dart';

class Device {
  final String id;
  final String? name;
  final int? lastOnline;
  final String? ipAddress;
  final bool online;
  final String? networkId;
  final String? nodeId;
  final String? deviceId;
  final String? clientVersion;

  Device({
    required this.id,
    this.name,
    this.lastOnline,
    this.ipAddress,
    required this.online,
    this.networkId,
    this.nodeId,
    this.deviceId,
    this.clientVersion,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    final lastOnline = json['lastOnline'];
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // 判断设备是否在线（假设5分钟内活跃为在线）
    final isOnline = lastOnline != null && 
                    lastOnline > 0 && 
                    (now - lastOnline) < Constants.onlineThreshold;

    return Device(
      id: json['id'] ?? json['nodeId'] ?? '',
      name: json['name'],
      lastOnline: lastOnline,
      ipAddress: (json['config']?['ipAssignments'] as List<dynamic>?)?.isNotEmpty == true
          ? json['config']['ipAssignments'][0]
          : null,
      online: isOnline,
      networkId: json['networkId'],
      nodeId: json['nodeId'],
      deviceId: json['config']?['id'] as String?,
      clientVersion: json['clientVersion'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastOnline': lastOnline,
      'ipAddress': ipAddress,
      'online': online ? 1 : 0,
      'networkId': networkId,
      'nodeId': nodeId,
      'deviceId': deviceId,
      'clientVersion': clientVersion,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'],
      name: map['name'],
      lastOnline: map['lastOnline'],
      ipAddress: map['ipAddress'],
      online: map['online'] == 1,
      networkId: map['networkId'],
      nodeId: map['nodeId'],
      deviceId: map['deviceId'],
      clientVersion: map['clientVersion'],
    );
  }
}