class SaasPlanEntity {
  final String id;
  final String name;
  final double price;
  final int monthlyPaymentLimit;
  final List<String> features;
  final bool isActive;

  const SaasPlanEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.monthlyPaymentLimit,
    required this.features,
    required this.isActive,
  });

  bool get isUnlimited => monthlyPaymentLimit == -1;

  SaasPlanEntity copyWith({
    String? id,
    String? name,
    double? price,
    int? monthlyPaymentLimit,
    List<String>? features,
    bool? isActive,
  }) {
    return SaasPlanEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      monthlyPaymentLimit: monthlyPaymentLimit ?? this.monthlyPaymentLimit,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
    );
  }
}
