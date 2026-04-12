import 'package:equatable/equatable.dart';
import '../../domain/entities/api_key_entity.dart';

abstract class DeveloperEvent extends Equatable {
  const DeveloperEvent();
  @override
  List<Object?> get props => [];
}

class InitializeDeveloperTools extends DeveloperEvent {
  const InitializeDeveloperTools();
}

class FetchApiKeys extends DeveloperEvent {
  final String brandId;
  const FetchApiKeys(this.brandId);
  @override
  List<Object?> get props => [brandId];
}

class GenerateApiKeys extends DeveloperEvent {
  final String brandId;
  final bool isSandbox;
  const GenerateApiKeys(this.brandId, {this.isSandbox = true});
  @override
  List<Object?> get props => [brandId, isSandbox];
}

class ToggleSandboxMode extends DeveloperEvent {
  final String brandId;
  final bool enabled;
  const ToggleSandboxMode(this.brandId, this.enabled);
  @override
  List<Object?> get props => [brandId, enabled];
}
