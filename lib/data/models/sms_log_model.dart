import '../../domain/entities/sms_log_entity.dart';

class SmsLogModel extends SmsLogEntity {
  const SmsLogModel({
    required super.id,
    required super.sender,
    required super.body,
    super.amount,
    super.trxId,
    required super.status,
    required super.createdAt,
  });

  factory SmsLogModel.fromJson(Map<String, dynamic> json) {
    return SmsLogModel(
      id: json['id'],
      sender: json['sender'] ?? 'Unknown',
      body: json['body'] ?? '',
      amount: json['amount'] != null
          ? (json['amount'] as num).toDouble()
          : null,
      trxId: json['trx_id'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'body': body,
      'amount': amount,
      'trx_id': trxId,
      'status': status,
    };
  }
}
