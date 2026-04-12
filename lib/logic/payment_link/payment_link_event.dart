import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_link_entity.dart';

abstract class PaymentLinkEvent extends Equatable {
  const PaymentLinkEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentLinks extends PaymentLinkEvent {}

class CreatePaymentLink extends PaymentLinkEvent {
  final PaymentLinkEntity link;
  const CreatePaymentLink(this.link);

  @override
  List<Object?> get props => [link];
}

class TogglePaymentLinkStatus extends PaymentLinkEvent {
  final String id;
  final bool isActive;
  const TogglePaymentLinkStatus(this.id, this.isActive);

  @override
  List<Object?> get props => [id, isActive];
}

class DeletePaymentLink extends PaymentLinkEvent {
  final String id;
  const DeletePaymentLink(this.id);

  @override
  List<Object?> get props => [id];
}
