import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SystemLogger {
  SystemLogger._internal();
  static final SystemLogger _instance = SystemLogger._internal();
  static SystemLogger get instance => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> info(
    String message, {
    String? source,
    String? merchantId,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      'info',
      message,
      source: source,
      merchantId: merchantId,
      metadata: metadata,
    );
  }

  Future<void> warning(
    String message, {
    String? source,
    String? merchantId,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      'warning',
      message,
      source: source,
      merchantId: merchantId,
      metadata: metadata,
    );
  }

  Future<void> error(
    String message, {
    String? source,
    String? merchantId,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      'error',
      message,
      source: source,
      merchantId: merchantId,
      metadata: metadata,
    );
  }

  Future<void> critical(
    String message, {
    String? source,
    String? merchantId,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      'critical',
      message,
      source: source,
      merchantId: merchantId,
      metadata: metadata,
    );
  }

  Future<void> _log(
    String level,
    String message, {
    String? source,
    String? merchantId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('📝 [SystemLogger] Logging [$level]: $message');

      await _supabase.from('system_logs').insert({
        'level': level,
        'source': source ?? 'app_client',
        'merchant_id': merchantId,
        'message': message,
        'metadata': metadata ?? {},
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('⚠️ [SystemLogger] Failed to save log to Supabase: $e');
      // Fallback to local debug print if DB logging fails
      debugPrint('FAILED LOG: [$level] $message | Meta: $metadata');
    }
  }
}
