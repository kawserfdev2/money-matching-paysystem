import 'package:equatable/equatable.dart';
import '../../domain/entities/api_key_entity.dart';

abstract class DeveloperState extends Equatable {
  const DeveloperState();
  @override
  List<Object?> get props => [];
}

class DeveloperInitial extends DeveloperState {}

class DeveloperLoading extends DeveloperState {}

class DeveloperKeysLoaded extends DeveloperState {
  final ApiKeyEntity? keys;
  final String? brandId;
  const DeveloperKeysLoaded(this.keys, {this.brandId});
  @override
  List<Object?> get props => [keys, brandId];
}

class DeveloperError extends DeveloperState {
  final String message;
  const DeveloperError(this.message);
  @override
  List<Object?> get props => [message];
}
