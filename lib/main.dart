import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/inventory_repository.dart';
import 'data/repositories/recipe_repository.dart';
import 'package:pantry_pal/data/database/database_helper.dart';
import 'package:pantry_pal/data/repositories/settings_repository.dart';
import 'package:pantry_pal/logic/inventory/inventory_bloc.dart';
import 'package:pantry_pal/logic/inventory/inventory_event.dart';
import 'package:pantry_pal/logic/recipe/recipe_bloc.dart';
import 'package:pantry_pal/logic/settings/settings_bloc.dart';
import 'package:pantry_pal/logic/settings/settings_event.dart';
import 'package:pantry_pal/logic/settings/settings_state.dart';
import 'package:pantry_pal/logic/shopping/shopping_bloc.dart';
import 'package:pantry_pal/logic/shopping/shopping_event.dart';
import 'package:pantry_pal/data/repositories/shopping_repository.dart';
import 'package:pantry_pal/logic/user/user_bloc.dart';
import 'package:pantry_pal/logic/user/user_event.dart';
import 'package:pantry_pal/data/repositories/user_repository.dart';
import 'package:pantry_pal/logic/auth/auth_bloc.dart';
import 'package:pantry_pal/logic/auth/auth_state.dart';
import 'package:pantry_pal/data/repositories/auth_repository.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/welcome_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/signup_screen.dart';
import 'ui/screens/splash_screen.dart';

void main() {
  if (kIsWeb) {
    // Web Initialization
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Desktop Initialization (Windows/Linux/Mac)
    // We can't strictly check Platform.isWindows here without dart:io,
    // but sqfliteFfiInit is safe to call if we are not on web/mobile usually.
    // However, since we are targeting Windows specifically + Web:
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const PantryPalApp());
}

class PantryPalApp extends StatelessWidget {
  const PantryPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InventoryBloc>(
          create:
              (context) => InventoryBloc(
                repository: InventoryRepository(helper: DatabaseHelper()),
              )..add(LoadInventory()),
        ),
        BlocProvider<SettingsBloc>(
          create:
              (context) =>
                  SettingsBloc(repository: SettingsRepository())
                    ..add(LoadSettings()),
        ),
        BlocProvider<RecipeBloc>(
          create: (context) => RecipeBloc(repository: RecipeRepository()),
        ),
        BlocProvider<ShoppingBloc>(
          create:
              (context) =>
                  ShoppingBloc(repository: ShoppingRepository())
                    ..add(LoadShoppingList()),
        ),
        BlocProvider<UserBloc>(
          create:
              (context) =>
                  UserBloc(repository: UserRepository())
                    ..add(LoadUserProfile()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'PantryPal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: settingsState.themeMode,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                switch (authState.status) {
                  case AuthStatus.authenticated:
                    return const HomeScreen();
                  case AuthStatus.unauthenticated:
                  case AuthStatus.error:
                  case AuthStatus.loading:
                    return const LoginScreen();
                  case AuthStatus.unknown:
                    return const SplashScreen();
                }
              },
            ),
            routes: {
              '/welcome': (_) => const WelcomeScreen(),
              '/home': (_) => const HomeScreen(),
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignupScreen(),
            },
          );
        },
      ),
    );
  }
}
