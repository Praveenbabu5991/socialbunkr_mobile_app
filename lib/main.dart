import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialbunkr_mobile_app/routes/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logic/blocs/authentication/authentication_bloc.dart';
import 'data/repositories/user_repository.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/landing_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: UserRepository())..add(AppStarted()),
      child: MaterialApp(
        title: "Social Bunkr",
        theme: ThemeData(
          primaryColor: const Color(0xFF0B3D2E),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0B3D2E),
            secondary: const Color(0xFFF5B400),
          ),
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
        ),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationAuthenticated) {
              return const HomePage();
            }
            if (state is AuthenticationUnauthenticated) {
              return const LandingPage();
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}