import 'package:amarpay/domain/repositories/automation_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/sms_log_entity.dart';
import '../models/sms_log_model.dart';

class AutomationRepositoryImpl implements AutomationRepository {
  final _supabase = Supabase.instance.client;

  @override
  Stream<List<SmsLogEntity>> watchSmsLogs() {
    return _supabase
        .from('sms_logs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => SmsLogModel.fromJson(json)).toList());
  }

  @override
  Future<void> syncSmsManually(String body, String sender) async {
    final parsed = await parseSms(body);

    await _supabase.from('sms_logs').insert({
      'sender': sender,
      'body': body,
      'amount': parsed['amount'],
      'trx_id': parsed['trx_id'],
      'status': 'pending',
    });
  }

  @override
  Future<Map<String, dynamic>> parseSms(String body) async {
    double? amount;
    String? trxId;

    // bKash Regex (Example: You have received tk 500.00 from ... TrxID 7H8I9J0K1L)
    final bKashAmountMatch = RegExp(
      r"received tk ([\d,.]+)",
    ).firstMatch(body.toLowerCase());
    final bKashTrxMatch = RegExp(r"TrxID ([A-Z0-9]+)").firstMatch(body);

    // Nagad Regex (Example: Cash In received. Amount: Tk 1,000.00. TxnID: 7H8I9J0K1L)
    final nagadAmountMatch = RegExp(r"Amount: Tk ([\d,.]+)").firstMatch(body);
    final nagadTrxMatch = RegExp(r"TxnID: ([A-Z0-9]+)").firstMatch(body);

    if (bKashAmountMatch != null) {
      amount = double.tryParse(bKashAmountMatch.group(1)!.replaceAll(',', ''));
      trxId = bKashTrxMatch?.group(1);
    } else if (nagadAmountMatch != null) {
      amount = double.tryParse(nagadAmountMatch.group(1)!.replaceAll(',', ''));
      trxId = nagadTrxMatch?.group(1);
    }

    return {'amount': amount, 'trx_id': trxId};
  }
}
