abstract class MerchantEvent {}

class LoadMerchants extends MerchantEvent {
  final bool isRefresh;
  LoadMerchants({this.isRefresh = false});
}

class LoadMoreMerchants extends MerchantEvent {}

class SearchMerchants extends MerchantEvent {
  final String query;
  SearchMerchants(this.query);
}

class FilterMerchants extends MerchantEvent {
  final String status; // 'all', 'active', 'suspended'
  FilterMerchants(this.status);
}

class ToggleMerchantStatus extends MerchantEvent {
  final String merchantId;
  final String currentStatus;
  final Function() onSuccess;
  final Function(String error) onError;

  ToggleMerchantStatus({
    required this.merchantId,
    required this.currentStatus,
    required this.onSuccess,
    required this.onError,
  });
}
