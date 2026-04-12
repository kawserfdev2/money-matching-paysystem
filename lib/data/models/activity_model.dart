import '../../domain/entities/activity_entity.dart';

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    super.userId,
    super.userName,
    required super.action,
    super.resource,
    super.metadata = const {},
    super.ipAddress,
    required super.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      userId: json['user_id'],
      userName: json['profiles']?['full_name'] ?? 'System',
      action: json['action'],
      resource: json['resource'],
      metadata: json['metadata'] ?? {},
      ipAddress: json['ip_address'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
