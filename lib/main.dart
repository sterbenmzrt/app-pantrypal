import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/inventory_repository.dart';
import 'data/repositories/recipe_repository.dart';
import 'logic/inventory/inventory_bloc.dart';
import 'logic/recipe/recipe_bloc.dart';
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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => InventoryRepository()),
        RepositoryProvider(create: (context) => RecipeRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => InventoryBloc(
                  repository: context.read<InventoryRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) =>
                    RecipeBloc(repository: context.read<RecipeRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'PantryPal',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
          routes: {
            '/welcome': (_) => const WelcomeScreen(),
            '/home': (_) => const HomeScreen(),
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignupScreen(),
          },
        ),
      ),
    );
  }
}
