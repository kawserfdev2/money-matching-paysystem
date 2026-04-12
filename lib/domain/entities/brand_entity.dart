import 'package:equatable/equatable.dart';

class BrandEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? faviconUrl;
  final String defaultCurrency;
  final String? supportEmail;
  final String? supportPhone;
  final Map<String, dynamic> settings;

  const BrandEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.faviconUrl,
    this.defaultCurrency = 'BDT',
    this.supportEmail,
    this.supportPhone,
    this.settings = const {},
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    logoUrl,
    faviconUrl,
    defaultCurrency,
    supportEmail,
    supportPhone,
    settings,
  ];
}
