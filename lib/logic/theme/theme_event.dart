import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ToggleThemeMode extends ThemeEvent {}

class ChangePrimaryColor extends ThemeEvent {
  final Color color;
  const ChangePrimaryColor(this.color);

  @override
  List<Object?> get props => [color];
}

class LoadThemeSettings extends ThemeEvent {}
