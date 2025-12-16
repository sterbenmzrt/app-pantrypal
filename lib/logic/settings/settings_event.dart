import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ChangeTheme extends SettingsEvent {
  final ThemeMode themeMode;
  const ChangeTheme(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}
