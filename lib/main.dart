import 'package:amarpay/core/injection.dart';
import 'package:amarpay/core/router/app_router.dart';
import 'package:amarpay/logic/auth/auth_bloc.dart';
import 'package:amarpay/logic/auth/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  setupInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(AppStarted()),
      child: MaterialApp.router(
        title: 'AmarPay Admin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        routerConfig: getIt<AppRouter>().router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
