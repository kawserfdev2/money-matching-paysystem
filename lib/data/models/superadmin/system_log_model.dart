import 'package:amarpay/domain/entities/system_log_entity.dart';

class SystemLogModel extends SystemLogEntity {
  const SystemLogModel({
    required super.id,
    required super.level,
    required super.source,
    super.merchantId,
    required super.message,
    required super.metadata,
    required super.isResolved,
    required super.createdAt,
  });

  factory SystemLogModel.fromJson(Map<String, dynamic> json) {
    return SystemLogModel(
      id: json['id'] as String,
      level: json['level'] as String,
      source: json['source'] as String,
      merchantId: json['merchant_id'] as String?,
      message: json['message'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isResolved: json['is_resolved'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'source': source,
      'merchant_id': merchantId,
      'message': message,
      'metadata': metadata,
      'is_resolved': isResolved,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
