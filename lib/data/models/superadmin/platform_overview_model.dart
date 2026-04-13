class PlatformOverviewModel {
  final int totalActiveMerchants;
  final double totalPlatformVolume;
  final int totalTransactions;
  final double todayVolume;

  PlatformOverviewModel({
    required this.totalActiveMerchants,
    required this.totalPlatformVolume,
    required this.totalTransactions,
    required this.todayVolume,
  });

  factory PlatformOverviewModel.fromJson(Map<String, dynamic> json) {
    return PlatformOverviewModel(
      totalActiveMerchants: json['total_active_merchants'] ?? 0,
      totalPlatformVolume: (json['total_platform_volume'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      todayVolume: (json['today_volume'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_active_merchants': totalActiveMerchants,
      'total_platform_volume': totalPlatformVolume,
      'total_transactions': totalTransactions,
      'today_volume': todayVolume,
    };
  }
}
