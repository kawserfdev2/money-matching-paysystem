import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String firstName;
  final String? lastName;
  final String email;
  final String phone;
  final String? company;
  final String? address;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;
  final String createdFrom; // 'checkout', 'manual'
  final DateTime createdAt;

  // Insights (Aggregated from payments)
  final double totalSpent;
  final int totalPayments;
  final double successRate;

  const CustomerEntity({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    required this.phone,
    this.company,
    this.address,
    this.city,
    this.state,
    this.postcode,
    this.country,
    required this.createdFrom,
    required this.createdAt,
    this.totalSpent = 0.0,
    this.totalPayments = 0,
    this.successRate = 0.0,
  });

  String get fullName => "$firstName ${lastName ?? ""}".trim();

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    company,
    address,
    city,
    state,
    postcode,
    country,
    createdFrom,
    createdAt,
    totalSpent,
    totalPayments,
    successRate,
  ];
}
