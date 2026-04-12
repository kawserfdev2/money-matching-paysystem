import 'package:amarpay/core/injection.dart';
import 'package:amarpay/core/router/app_router.dart';
import 'package:amarpay/logic/auth/auth_bloc.dart';
import 'package:amarpay/logic/auth/auth_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amarpay/logic/theme/theme_bloc.dart';
import 'package:amarpay/logic/theme/theme_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  setupInjection();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AuthBloc>()..add(AppStarted())),
        BlocProvider(create: (context) => getIt<ThemeBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'AmarPay Admin',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeState.primaryColor,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Inter',
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeState.primaryColor,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              fontFamily: 'Inter',
            ),
            themeMode: themeState.themeMode,
            routerConfig: getIt<AppRouter>().router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
