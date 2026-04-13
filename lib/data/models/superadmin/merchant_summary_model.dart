class MerchantSummaryModel {
  final String merchantId;
  final String brandName;
  final String ownerEmail;
  final double totalProcessedVolume;
  final DateTime joinedDate;
  final String status;

  MerchantSummaryModel({
    required this.merchantId,
    required this.brandName,
    required this.ownerEmail,
    required this.totalProcessedVolume,
    required this.joinedDate,
    required this.status,
  });

  factory MerchantSummaryModel.fromJson(Map<String, dynamic> json) {
    return MerchantSummaryModel(
      merchantId: json['merchant_id'] ?? '',
      brandName: json['brand_name'] ?? 'N/A',
      ownerEmail: json['owner_email'] ?? '',
      totalProcessedVolume: (json['total_processed_volume'] ?? 0).toDouble(),
      joinedDate:
          DateTime.tryParse(json['joined_date']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status'] ?? 'active',
    );
  }

  MerchantSummaryModel copyWith({
    String? merchantId,
    String? brandName,
    String? ownerEmail,
    double? totalProcessedVolume,
    DateTime? joinedDate,
    String? status,
  }) {
    return MerchantSummaryModel(
      merchantId: merchantId ?? this.merchantId,
      brandName: brandName ?? this.brandName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      totalProcessedVolume: totalProcessedVolume ?? this.totalProcessedVolume,
      joinedDate: joinedDate ?? this.joinedDate,
      status: status ?? this.status,
    );
  }
}
