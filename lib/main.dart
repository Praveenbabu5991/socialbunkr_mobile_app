import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      initialRoute: AppRouter.landing,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}