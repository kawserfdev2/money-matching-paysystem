import 'package:equatable/equatable.dart';

class ApiKeyEntity extends Equatable {
  final String id;
  final String brandId;
  final String publicKey;
  final String secretKey;
  final bool isSandbox;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final String? label;

  const ApiKeyEntity({
    required this.id,
    required this.brandId,
    required this.publicKey,
    required this.secretKey,
    required this.isSandbox,
    required this.createdAt,
    this.lastUsedAt,
    this.label,
  });

  @override
  List<Object?> get props => [
    id,
    brandId,
    publicKey,
    secretKey,
    isSandbox,
    createdAt,
    lastUsedAt,
    label,
  ];
}
