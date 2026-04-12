import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.firstName,
    super.lastName,
    required super.email,
    required super.phone,
    super.company,
    super.address,
    super.city,
    super.state,
    super.postcode,
    super.country,
    required super.createdFrom,
    required super.createdAt,
    super.totalSpent = 0.0,
    super.totalPayments = 0,
    super.successRate = 0.0,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    // Handle potential aggregation data from Supabase joins
    final payments = json['payments'] as List?;
    double totalSpent = 0.0;
    int totalPayments = 0;
    int successCount = 0;

    if (payments != null) {
      totalPayments = payments.length;
      for (var p in payments) {
        final amount = (p['amount'] ?? 0).toDouble();
        totalSpent += amount;
        if (p['status']?.toString().toLowerCase() == 'completed') {
          successCount++;
        }
      }
    }

    return CustomerModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      company: json['company'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
      createdFrom: json['created_from'] ?? 'manual',
      createdAt: DateTime.parse(json['created_at']),
      totalSpent: totalSpent,
      totalPayments: totalPayments,
      successRate: totalPayments > 0
          ? (successCount / totalPayments) * 100
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'company': company,
      'address': address,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
      'created_from': createdFrom,
    };
  }
}
