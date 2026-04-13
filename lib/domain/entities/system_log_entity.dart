import 'package:equatable/equatable.dart';

class SystemLogEntity extends Equatable {
  final String id;
  final String level;
  final String source;
  final String? merchantId;
  final String message;
  final Map<String, dynamic> metadata;
  final bool isResolved;
  final DateTime createdAt;

  const SystemLogEntity({
    required this.id,
    required this.level,
    required this.source,
    this.merchantId,
    required this.message,
    required this.metadata,
    required this.isResolved,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    level,
    source,
    merchantId,
    message,
    metadata,
    isResolved,
    createdAt,
  ];
}
