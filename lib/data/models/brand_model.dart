import '../../domain/entities/brand_entity.dart';

class BrandModel extends BrandEntity {
  const BrandModel({
    required super.id,
    required super.name,
    required super.slug,
    super.logoUrl,
    super.faviconUrl,
    super.defaultCurrency = 'BDT',
    super.supportEmail,
    super.supportPhone,
    super.settings = const {},
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    final settings = json['settings'] as Map<String, dynamic>? ?? {};
    return BrandModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      logoUrl: json['logo_url'],
      faviconUrl: settings['favicon_url'],
      defaultCurrency: json['currency'] ?? 'BDT',
      supportEmail: settings['support_email'],
      supportPhone: settings['support_phone'],
      settings: settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'logo_url': logoUrl,
      'currency': defaultCurrency,
      'settings': {
        ...settings,
        'favicon_url': faviconUrl,
        'support_email': supportEmail,
        'support_phone': supportPhone,
      },
    };
  }
}
