import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/payment_link_repository.dart';
import 'payment_link_event.dart';
import 'payment_link_state.dart';

class PaymentLinkBloc extends Bloc<PaymentLinkEvent, PaymentLinkState> {
  final PaymentLinkRepository _repository;

  PaymentLinkBloc(this._repository) : super(PaymentLinkInitial()) {
    on<LoadPaymentLinks>(_onLoadLinks);
    on<CreatePaymentLink>(_onCreateLink);
    on<TogglePaymentLinkStatus>(_onToggleStatus);
    on<DeletePaymentLink>(_onDeleteLink);
  }

  Future<void> _onLoadLinks(
    LoadPaymentLinks event,
    Emitter<PaymentLinkState> emit,
  ) async {
    emit(PaymentLinkLoading());
    try {
      final links = await _repository.getPaymentLinks();
      emit(PaymentLinkLoaded(links));
    } catch (e) {
      emit(PaymentLinkError(e.toString()));
    }
  }

  Future<void> _onCreateLink(
    CreatePaymentLink event,
    Emitter<PaymentLinkState> emit,
  ) async {
    emit(PaymentLinkLoading());
    try {
      await _repository.createPaymentLink(event.link);
      emit(
        const PaymentLinkActionSuccess("Payment link created successfully!"),
      );
      add(LoadPaymentLinks());
    } catch (e) {
      emit(PaymentLinkError(e.toString()));
    }
  }

  Future<void> _onToggleStatus(
    TogglePaymentLinkStatus event,
    Emitter<PaymentLinkState> emit,
  ) async {
    try {
      await _repository.updatePaymentLinkStatus(event.id, event.isActive);
      add(LoadPaymentLinks());
    } catch (e) {
      emit(PaymentLinkError(e.toString()));
    }
  }

  Future<void> _onDeleteLink(
    DeletePaymentLink event,
    Emitter<PaymentLinkState> emit,
  ) async {
    try {
      await _repository.deletePaymentLink(event.id);
      add(LoadPaymentLinks());
    } catch (e) {
      emit(PaymentLinkError(e.toString()));
    }
  }
}
