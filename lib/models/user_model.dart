class ZeroTierUser {
  final String id;
  final String? orgId;
  final String? displayName;
  final String? email;
  final String? smsNumber;
  final List<String> tokens;

  const ZeroTierUser({
    required this.id,
    this.orgId,
    this.displayName,
    this.email,
    this.smsNumber,
    this.tokens = const [],
  });

  factory ZeroTierUser.fromJson(Map<String, dynamic> json) {
    return ZeroTierUser(
      id: json['id']?.toString() ?? '',
      orgId: json['orgId']?.toString(),
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      smsNumber: json['smsNumber'] as String?,
      tokens: (json['tokens'] as List<dynamic>? ?? const [])
          .map((dynamic item) => item.toString())
          .toList(),
    );
  }

  ZeroTierUser copyWith({
    String? id,
    String? orgId,
    String? displayName,
    bool clearDisplayName = false,
    String? email,
    String? smsNumber,
    bool clearSmsNumber = false,
    List<String>? tokens,
  }) {
    return ZeroTierUser(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      displayName:
          clearDisplayName ? null : (displayName ?? this.displayName),
      email: email ?? this.email,
      smsNumber: clearSmsNumber ? null : (smsNumber ?? this.smsNumber),
      tokens: tokens ?? this.tokens,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'displayName': displayName,
      'smsNumber': smsNumber,
    };
  }
}

class ZeroTierStatus {
  final String? version;
  final String? apiVersion;
  final bool readOnlyMode;
  final ZeroTierUser? user;

  const ZeroTierStatus({
    this.version,
    this.apiVersion,
    required this.readOnlyMode,
    this.user,
  });

  factory ZeroTierStatus.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    return ZeroTierStatus(
      version: json['version'] as String?,
      apiVersion: json['apiVersion']?.toString(),
      readOnlyMode: json['readOnlyMode'] == true,
      user: userJson == null ? null : ZeroTierUser.fromJson(userJson),
    );
  }
}

class GeneratedApiToken {
  final String token;
  final String? hex;

  const GeneratedApiToken({required this.token, this.hex});

  factory GeneratedApiToken.fromJson(Map<String, dynamic> json) {
    return GeneratedApiToken(
      token: json['token']?.toString() ?? '',
      hex: json['hex']?.toString(),
    );
  }
}