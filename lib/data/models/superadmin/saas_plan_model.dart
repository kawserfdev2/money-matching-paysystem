import '../../../domain/entities/saas_plan_entity.dart';

class SaasPlanModel extends SaasPlanEntity {
  const SaasPlanModel({
    required super.id,
    required super.name,
    required super.price,
    required super.monthlyPaymentLimit,
    required super.features,
    required super.isActive,
  });

  factory SaasPlanModel.fromJson(Map<String, dynamic> json) {
    return SaasPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      monthlyPaymentLimit: (json['monthly_payment_limit'] as num).toInt(),
      features: (json['features'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'monthly_payment_limit': monthlyPaymentLimit,
      'features': features,
      'is_active': isActive,
    };
  }

  factory SaasPlanModel.fromEntity(SaasPlanEntity entity) {
    return SaasPlanModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      monthlyPaymentLimit: entity.monthlyPaymentLimit,
      features: entity.features,
      isActive: entity.isActive,
    );
  }
}
