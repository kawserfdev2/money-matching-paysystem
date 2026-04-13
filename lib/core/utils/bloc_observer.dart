import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('🔵 [BLOC EVENT] ${bloc.runtimeType} -> $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // Silent for basic changes to avoid spamming unless they are transitions
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(
      '🔄 [BLOC TRANSITION] ${bloc.runtimeType}: ${transition.currentState} -> ${transition.nextState}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('🔴 [BLOC ERROR] ${bloc.runtimeType} -> $error');
    super.onError(bloc, error, stackTrace);
  }
}
