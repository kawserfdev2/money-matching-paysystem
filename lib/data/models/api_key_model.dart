import '../../domain/entities/api_key_entity.dart';

class ApiKeyModel extends ApiKeyEntity {
  const ApiKeyModel({
    required super.id,
    required super.brandId,
    required super.publicKey,
    required super.secretKey,
    required super.isSandbox,
    required super.createdAt,
    super.lastUsedAt,
    super.label,
  });

  factory ApiKeyModel.fromJson(Map<String, dynamic> json) {
    return ApiKeyModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      publicKey: json['public_key'] as String,
      secretKey: json['secret_key'] as String,
      isSandbox: json['is_sandbox'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUsedAt: json['last_used_at'] != null
          ? DateTime.parse(json['last_used_at'] as String)
          : null,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': brandId,
      'public_key': publicKey,
      'secret_key': secretKey,
      'is_sandbox': isSandbox,
      'label': label,
    };
  }
}
