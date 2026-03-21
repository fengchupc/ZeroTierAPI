import 'package:zerotierapi/utils/constants.dart';

class Device {
  final String id;
  final String? name;
  final String? description;
  final int? lastOnline;
  final String? ipAddress;
  final String? physicalAddress;
  final bool online;
  final String? networkId;
  final String? nodeId;
  final String? deviceId;
  final String? clientVersion;
  final bool hidden;
  final bool? authorized;
  final bool noAutoAssignIps;
  final bool activeBridge;
  final bool ssoExempt;
  final List<String> ipAssignments;

  Device({
    required this.id,
    this.name,
    this.description,
    this.lastOnline,
    this.ipAddress,
    this.physicalAddress,
    required this.online,
    this.networkId,
    this.nodeId,
    this.deviceId,
    this.clientVersion,
    this.hidden = false,
    this.authorized,
    this.noAutoAssignIps = false,
    this.activeBridge = false,
    this.ssoExempt = false,
    this.ipAssignments = const [],
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    final config = json['config'] as Map<String, dynamic>? ?? const {};
    final lastOnline = json['lastOnline'];
    final now = DateTime.now().millisecondsSinceEpoch;
    final ipAssignments = (config['ipAssignments'] as List<dynamic>? ?? const [])
        .map((dynamic item) => item.toString())
        .toList();
    
    // 判断设备是否在线（假设5分钟内活跃为在线）
    final isOnline = lastOnline != null && 
                    lastOnline > 0 && 
                    (now - lastOnline) < Constants.onlineThreshold;

    return Device(
      id: json['id'] ?? json['nodeId'] ?? '',
      name: json['name'],
      description: json['description'] as String?,
      lastOnline: lastOnline,
      ipAddress: ipAssignments.isNotEmpty ? ipAssignments.first : null,
      physicalAddress: json['physicalAddress'] as String?,
      online: isOnline,
      networkId: json['networkId'],
      nodeId: json['nodeId'],
      deviceId: config['id'] as String?,
      clientVersion: json['clientVersion'] as String?,
      hidden: json['hidden'] == true,
      authorized: config['authorized'] as bool?,
      noAutoAssignIps: config['noAutoAssignIps'] == true,
      activeBridge: config['activeBridge'] == true,
      ssoExempt: config['ssoExempt'] == true,
      ipAssignments: ipAssignments,
    );
  }

  Device copyWith({
    String? id,
    String? name,
    bool clearName = false,
    String? description,
    bool clearDescription = false,
    int? lastOnline,
    String? ipAddress,
    String? physicalAddress,
    bool? online,
    String? networkId,
    String? nodeId,
    String? deviceId,
    String? clientVersion,
    bool? hidden,
    bool? authorized,
    bool clearAuthorized = false,
    bool? noAutoAssignIps,
    bool? activeBridge,
    bool? ssoExempt,
    List<String>? ipAssignments,
  }) {
    return Device(
      id: id ?? this.id,
      name: clearName ? null : (name ?? this.name),
      description: clearDescription ? null : (description ?? this.description),
      lastOnline: lastOnline ?? this.lastOnline,
      ipAddress: ipAddress ?? this.ipAddress,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      online: online ?? this.online,
      networkId: networkId ?? this.networkId,
      nodeId: nodeId ?? this.nodeId,
      deviceId: deviceId ?? this.deviceId,
      clientVersion: clientVersion ?? this.clientVersion,
      hidden: hidden ?? this.hidden,
      authorized: clearAuthorized ? null : (authorized ?? this.authorized),
      noAutoAssignIps: noAutoAssignIps ?? this.noAutoAssignIps,
      activeBridge: activeBridge ?? this.activeBridge,
      ssoExempt: ssoExempt ?? this.ssoExempt,
      ipAssignments: ipAssignments ?? this.ipAssignments,
    );
  }

  Map<String, dynamic> toMemberUpdateJson() {
    return {
      'hidden': hidden,
      'name': name,
      'description': description,
      'config': {
        if (authorized != null) 'authorized': authorized,
        'ipAssignments': ipAssignments,
        'noAutoAssignIps': noAutoAssignIps,
        'activeBridge': activeBridge,
        'ssoExempt': ssoExempt,
      },
    };
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