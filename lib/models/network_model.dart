class ZeroTierNetwork {
  final String id;
  final String? name;
  final String? description;
  final String? rulesSource;
  final bool? isPrivate;
  final int? mtu;
  final bool? enableBroadcast;
  final int? multicastLimit;
  final Map<String, dynamic> config;

  const ZeroTierNetwork({
    required this.id,
    required this.config,
    this.name,
    this.description,
    this.rulesSource,
    this.isPrivate,
    this.mtu,
    this.enableBroadcast,
    this.multicastLimit,
  });

  factory ZeroTierNetwork.fromJson(Map<String, dynamic> json) {
    final config = Map<String, dynamic>.from(
      json['config'] as Map<String, dynamic>? ?? const {},
    );

    return ZeroTierNetwork(
      id: json['id']?.toString() ?? '',
      config: config,
      name: config['name'] as String?,
      description: json['description'] as String?,
      rulesSource: json['rulesSource'] as String?,
      isPrivate: config['private'] as bool?,
      mtu: config['mtu'] as int?,
      enableBroadcast: config['enableBroadcast'] as bool?,
      multicastLimit: config['multicastLimit'] as int?,
    );
  }

  ZeroTierNetwork copyWith({
    String? id,
    String? name,
    bool clearName = false,
    String? description,
    bool clearDescription = false,
    String? rulesSource,
    bool clearRulesSource = false,
    bool? isPrivate,
    int? mtu,
    bool? enableBroadcast,
    int? multicastLimit,
    Map<String, dynamic>? config,
  }) {
    return ZeroTierNetwork(
      id: id ?? this.id,
      config: config ?? this.config,
      name: clearName ? null : (name ?? this.name),
      description: clearDescription ? null : (description ?? this.description),
      rulesSource:
          clearRulesSource ? null : (rulesSource ?? this.rulesSource),
      isPrivate: isPrivate ?? this.isPrivate,
      mtu: mtu ?? this.mtu,
      enableBroadcast: enableBroadcast ?? this.enableBroadcast,
      multicastLimit: multicastLimit ?? this.multicastLimit,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    final nextConfig = Map<String, dynamic>.from(config);

    if (name != null) {
      nextConfig['name'] = name;
    }
    if (isPrivate != null) {
      nextConfig['private'] = isPrivate;
    }
    if (mtu != null) {
      nextConfig['mtu'] = mtu;
    }
    if (enableBroadcast != null) {
      nextConfig['enableBroadcast'] = enableBroadcast;
    }
    if (multicastLimit != null) {
      nextConfig['multicastLimit'] = multicastLimit;
    }

    return {
      'config': nextConfig,
      'description': description,
      'rulesSource': rulesSource,
    };
  }
}