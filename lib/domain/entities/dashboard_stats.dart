import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalPayments;
  final int pendingPayments;
  final int unpaidInvoices;
  final int pendingSms;
  final List<double> weeklyVolume;

  const DashboardStats({
    required this.totalPayments,
    required this.pendingPayments,
    required this.unpaidInvoices,
    required this.pendingSms,
    required this.weeklyVolume,
  });

  @override
  List<Object?> get props => [
    totalPayments,
    pendingPayments,
    unpaidInvoices,
    pendingSms,
    weeklyVolume,
  ];
}
