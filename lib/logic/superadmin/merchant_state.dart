import '../../data/models/superadmin/merchant_summary_model.dart';

abstract class MerchantState {}

class MerchantInitial extends MerchantState {}

class MerchantLoading extends MerchantState {}

class MerchantLoaded extends MerchantState {
  final List<MerchantSummaryModel> merchants;
  final bool hasReachedMax;
  final String query;
  final String statusFilter;

  MerchantLoaded({
    required this.merchants,
    required this.hasReachedMax,
    this.query = '',
    this.statusFilter = 'all',
  });

  MerchantLoaded copyWith({
    List<MerchantSummaryModel>? merchants,
    bool? hasReachedMax,
    String? query,
    String? statusFilter,
  }) {
    return MerchantLoaded(
      merchants: merchants ?? this.merchants,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: query ?? this.query,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class MerchantError extends MerchantState {
  final String message;
  MerchantError(this.message);
}
