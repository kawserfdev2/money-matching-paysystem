import 'package:equatable/equatable.dart';

class SmsLogEntity extends Equatable {
  final String id;
  final String sender;
  final String body;
  final double? amount;
  final String? trxId;
  final String status; // 'matched', 'unmatched', 'pending'
  final DateTime createdAt;

  const SmsLogEntity({
    required this.id,
    required this.sender,
    required this.body,
    this.amount,
    this.trxId,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    sender,
    body,
    amount,
    trxId,
    status,
    createdAt,
  ];
}
