import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/payment_link_repository.dart';
import '../../domain/repositories/gateway_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/entities/payment_entity.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final PaymentLinkRepository _linkRepository;
  final GatewayRepository _gatewayRepository;
  final PaymentRepository _paymentRepository;

  CheckoutBloc({
    required PaymentLinkRepository linkRepository,
    required GatewayRepository gatewayRepository,
    required PaymentRepository paymentRepository,
  }) : _linkRepository = linkRepository,
       _gatewayRepository = gatewayRepository,
       _paymentRepository = paymentRepository,
       super(CheckoutInitial()) {
    on<LoadCheckoutDetails>(_onLoadDetails);
    on<SelectPaymentGateway>(_onSelectGateway);
    on<InitiateCheckoutPayment>(_onInitiatePayment);
  }

  Future<void> _onLoadDetails(
    LoadCheckoutDetails event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    try {
      final link = await _linkRepository.getPaymentLinkBySlug(event.slug);
      if (link == null) {
        emit(const CheckoutInvalid("Payment link not found."));
        return;
      }

      if (!link.isActive) {
        emit(const CheckoutInvalid("This payment link has been disabled."));
        return;
      }

      if (link.isExpired) {
        emit(const CheckoutInvalid("This payment link has expired."));
        return;
      }

      final gateways = await _gatewayRepository.getGateways();
      final activeGateways = gateways.where((g) => g.isActive).toList();

      emit(
        CheckoutLoaded(
          link: link,
          gateways: activeGateways,
          selectedGateway: activeGateways.isNotEmpty
              ? activeGateways.first
              : null,
        ),
      );
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

  void _onSelectGateway(
    SelectPaymentGateway event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is CheckoutLoaded) {
      emit((state as CheckoutLoaded).copyWith(selectedGateway: event.gateway));
    }
  }

  Future<void> _onInitiatePayment(
    InitiateCheckoutPayment event,
    Emitter<CheckoutState> emit,
  ) async {
    final currentState = state;
    if (currentState is CheckoutLoaded &&
        currentState.selectedGateway != null) {
      emit(CheckoutProcessing());
      try {
        final payment = PaymentEntity(
          id: '',
          customerEmail: event.customerEmail,
          gateway: currentState.selectedGateway!.name,
          amount: currentState.link.amount,
          netAmount:
              currentState.link.amount, // For now, netAmount is same as amount
          status: 'pending',
          transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          currency: currentState.link.currency,
          createdAt: DateTime.now(),
          metadata: {
            'link_id': currentState.link.id,
            'link_slug': currentState.link.slug,
            'customer_name': event.customerName,
            'customer_phone': event.customerPhone,
          },
        );

        await _paymentRepository.createPayment(payment);

        emit(
          CheckoutSuccess(
            transactionId: payment.transactionId,
            redirectUrl: currentState.link.redirectUrl,
          ),
        );
      } catch (e) {
        emit(CheckoutError(e.toString()));
      }
    }
  }
}
