import 'package:equatable/equatable.dart';
import '../../domain/entities/brand_entity.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateBrandInfo extends SettingsEvent {
  final BrandEntity brand;
  const UpdateBrandInfo(this.brand);
  @override
  List<Object?> get props => [brand];
}

class UploadLogo extends SettingsEvent {
  final String filePath;
  final String fileName;
  const UploadLogo(this.filePath, this.fileName);
  @override
  List<Object?> get props => [filePath, fileName];
}
