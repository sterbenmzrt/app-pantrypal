import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:io' show Platform;
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
import 'package:pantry_pal/data/repositories/shopping_list_repository.dart';
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

// Global navigator key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // CRITICAL: Must be called before using any plugins
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web Initialization
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Desktop Initialization (Windows/Linux/Mac) - requires FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // For Android/iOS, sqflite works natively - no initialization needed

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
                  ShoppingBloc(repository: ShoppingListRepository())
                    ..add(LoadShoppingLists()),
        ),
        BlocProvider<UserBloc>(
          create:
              (context) =>
                  UserBloc(repository: UserRepository())
                    ..add(LoadUserProfile()),
        ),
        BlocProvider<AuthBloc>(
          create:
              (context) => AuthBloc(
                authRepository: AuthRepository(),
                settingsRepository: SettingsRepository(),
              ),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          // Only listen when transitioning from authenticated to unauthenticated (logout)
          return previous.status == AuthStatus.authenticated &&
              current.status == AuthStatus.unauthenticated;
        },
        listener: (context, authState) async {
          // Clear all user-specific data on logout
          await DatabaseHelper().clearAllUserData();
          // Clear user profile data on logout
          context.read<UserBloc>().add(ClearUserProfile());
          // Clear shopping list state
          context.read<ShoppingBloc>().add(LoadShoppingLists());
          // Clear inventory state
          context.read<InventoryBloc>().add(LoadInventory());
          // Use the global navigator key to navigate
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'PantryPal',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
                textTheme: GoogleFonts.plusJakartaSansTextTheme(
                  ThemeData.dark().textTheme,
                ),
              ),
              themeMode: settingsState.themeMode,
              // Use SplashScreen as initial home - it handles the auth check and navigation
              home: const _AuthGate(),
              routes: {
                '/welcome': (_) => const WelcomeScreen(),
                '/home': (_) => const HomeScreen(),
                '/login': (_) => const LoginScreen(),
                '/signup': (_) => const SignupScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}

/// A gate widget that listens to auth state changes and navigates accordingly.
/// Uses BlocListener instead of BlocBuilder to avoid rebuilding and overriding
/// any navigation that has already occurred (e.g., from welcome to login screen).
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Only navigate if we haven't already navigated from this gate
        if (_hasNavigated) return;

        switch (state.status) {
          case AuthStatus.authenticated:
            _hasNavigated = true;
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
            break;
          case AuthStatus.firstLaunch:
            _hasNavigated = true;
            Navigator.of(context).pushReplacementNamed('/welcome');
            break;
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            _hasNavigated = true;
            Navigator.of(context).pushReplacementNamed('/login');
            break;
          case AuthStatus.unknown:
          case AuthStatus.loading:
            // Stay on splash screen
            break;
        }
      },
      child: const SplashScreen(),
    );
  }
}
