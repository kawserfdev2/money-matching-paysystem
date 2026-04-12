import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_link_entity.dart';

abstract class PaymentLinkState extends Equatable {
  const PaymentLinkState();

  @override
  List<Object?> get props => [];
}

class PaymentLinkInitial extends PaymentLinkState {}

class PaymentLinkLoading extends PaymentLinkState {}

class PaymentLinkLoaded extends PaymentLinkState {
  final List<PaymentLinkEntity> links;
  const PaymentLinkLoaded(this.links);

  @override
  List<Object?> get props => [links];
}

class PaymentLinkActionSuccess extends PaymentLinkState {
  final String message;
  final PaymentLinkEntity? createdLink;
  const PaymentLinkActionSuccess(this.message, {this.createdLink});

  @override
  List<Object?> get props => [message, createdLink];
}

class PaymentLinkError extends PaymentLinkState {
  final String message;
  const PaymentLinkError(this.message);

  @override
  List<Object?> get props => [message];
}
