import 'package:equatable/equatable.dart';

class ActivityEntity extends Equatable {
  final String id;
  final String? userId; // Null if system action
  final String? userName;
  final String action;
  final String? resource;
  final Map<String, dynamic> metadata;
  final String? ipAddress;
  final DateTime createdAt;

  const ActivityEntity({
    required this.id,
    this.userId,
    this.userName,
    required this.action,
    this.resource,
    this.metadata = const {},
    this.ipAddress,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    action,
    resource,
    metadata,
    ipAddress,
    createdAt,
  ];
}
