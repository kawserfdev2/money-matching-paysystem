import 'package:equatable/equatable.dart';
import '../../domain/entities/gateway_entity.dart';
import '../../domain/entities/payment_link_entity.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadCheckoutDetails extends CheckoutEvent {
  final String slug;
  const LoadCheckoutDetails(this.slug);

  @override
  List<Object?> get props => [slug];
}

class SelectPaymentGateway extends CheckoutEvent {
  final GatewayEntity gateway;
  const SelectPaymentGateway(this.gateway);

  @override
  List<Object?> get props => [gateway];
}

class InitiateCheckoutPayment extends CheckoutEvent {
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  const InitiateCheckoutPayment({
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
  });

  @override
  List<Object?> get props => [customerName, customerEmail, customerPhone];
}
