import '../../../domain/entities/subscription_detail_entity.dart';

class SubscriptionDetailModel extends SubscriptionDetailEntity {
  const SubscriptionDetailModel({
    required super.id,
    required super.brandId,
    required super.planId,
    required super.startDate,
    required super.endDate,
    required super.billingCycle,
    required super.status,
    required super.brandName,
    required super.planName,
    required super.planPrice,
  });

  factory SubscriptionDetailModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetailModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      planId: json['plan_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      billingCycle: json['billing_cycle'] as String,
      status: json['status'] as String,
      brandName: json['brand_name'] as String,
      planName: json['plan_name'] as String,
      planPrice: (json['plan_price'] as num).toDouble(),
    );
  }
}
