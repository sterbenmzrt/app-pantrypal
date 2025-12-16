import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeTheme>(_onChangeTheme);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final themeMode = await repository.getThemeMode();
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveThemeMode(event.themeMode);
    emit(state.copyWith(themeMode: event.themeMode));
  }
}
