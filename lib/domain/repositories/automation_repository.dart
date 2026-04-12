import 'package:amarpay/domain/entities/sms_log_entity.dart';

abstract class AutomationRepository {
  Stream<List<SmsLogEntity>> watchSmsLogs();
  Future<void> syncSmsManually(String body, String sender);
  Future<Map<String, dynamic>> parseSms(String body);
}
