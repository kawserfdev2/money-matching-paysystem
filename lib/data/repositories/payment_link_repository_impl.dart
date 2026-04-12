import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/payment_link_entity.dart';
import '../../domain/repositories/payment_link_repository.dart';
import '../models/payment_link_model.dart';

class PaymentLinkRepositoryImpl implements PaymentLinkRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<PaymentLinkEntity>> getPaymentLinks() async {
    final response = await _supabase
        .from('payment_links')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => PaymentLinkModel.fromJson(json))
        .toList();
  }

  @override
  Future<PaymentLinkEntity?> getPaymentLinkBySlug(String slug) async {
    try {
      final response = await _supabase
          .from('payment_links')
          .select()
          .eq('slug', slug)
          .maybeSingle();

      if (response == null) return null;
      return PaymentLinkModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createPaymentLink(PaymentLinkEntity link) async {
    final slug = await _generateUniqueSlug();
    final model = PaymentLinkModel(
      id: '',
      slug: slug,
      productName: link.productName,
      description: link.description,
      amount: link.amount,
      currency: link.currency,
      expiryDate: link.expiryDate,
      redirectUrl: link.redirectUrl,
      stockLimit: link.stockLimit,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _supabase.from('payment_links').insert(model.toJson());
  }

  @override
  Future<void> updatePaymentLinkStatus(String id, bool isActive) async {
    await _supabase
        .from('payment_links')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  @override
  Future<void> deletePaymentLink(String id) async {
    await _supabase.from('payment_links').delete().eq('id', id);
  }

  Future<String> _generateUniqueSlug() async {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();

    while (true) {
      final slug = String.fromCharCodes(
        Iterable.generate(
          8,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
        ),
      );

      final existing = await _supabase
          .from('payment_links')
          .select('slug')
          .eq('slug', slug)
          .maybeSingle();

      if (existing == null) return slug;
    }
  }
}
