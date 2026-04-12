import 'package:equatable/equatable.dart';
import '../../domain/entities/gateway_entity.dart';
import '../../domain/entities/payment_link_entity.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutLoaded extends CheckoutState {
  final PaymentLinkEntity link;
  final List<GatewayEntity> gateways;
  final GatewayEntity? selectedGateway;

  const CheckoutLoaded({
    required this.link,
    required this.gateways,
    this.selectedGateway,
  });

  CheckoutLoaded copyWith({GatewayEntity? selectedGateway}) {
    return CheckoutLoaded(
      link: link,
      gateways: gateways,
      selectedGateway: selectedGateway ?? this.selectedGateway,
    );
  }

  @override
  List<Object?> get props => [link, gateways, selectedGateway];
}

class CheckoutProcessing extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final String transactionId;
  final String? redirectUrl;

  const CheckoutSuccess({required this.transactionId, this.redirectUrl});

  @override
  List<Object?> get props => [transactionId, redirectUrl];
}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}

class CheckoutInvalid extends CheckoutState {
  final String reason;
  const CheckoutInvalid(this.reason);

  @override
  List<Object?> get props => [reason];
}
