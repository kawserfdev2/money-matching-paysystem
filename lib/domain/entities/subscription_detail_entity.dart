class SubscriptionDetailEntity {
  final String id;
  final String brandId;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final String billingCycle;
  final String status;
  final String brandName;
  final String planName;
  final double planPrice;

  const SubscriptionDetailEntity({
    required this.id,
    required this.brandId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.billingCycle,
    required this.status,
    required this.brandName,
    required this.planName,
    required this.planPrice,
  });
}
