import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/pages/add_property_page.dart';
import 'package:flutter_application_1/presentation/pages/home_page.dart';
import 'package:flutter_application_1/presentation/pages/landing_page.dart';
import 'package:flutter_application_1/presentation/pages/login_page.dart';
import 'package:flutter_application_1/presentation/pages/register_page.dart';
import 'package:flutter_application_1/presentation/pages/verify_property_page.dart';
import 'package:flutter_application_1/presentation/pages/property_detail_page.dart';
import 'package:flutter_application_1/presentation/pages/host_dashboard_page.dart'; // Added

class AppRouter {
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addProperty = '/add-property';
  static const String verifyProperty = '/verify-property';
  static const String propertyDetail = '/property-detail';
  static const String hostDashboard = '/host-dashboard'; // Added

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landing:
        return MaterialPageRoute(builder: (_) => const LandingPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case addProperty:
        return MaterialPageRoute(builder: (_) => const AddPropertyPage());
      case verifyProperty:
        final propertyId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => VerifyPropertyPage(propertyId: propertyId));
      case propertyDetail:
        final propertyId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => PropertyDetailPage(propertyId: propertyId));
      case hostDashboard: // Added
        return MaterialPageRoute(builder: (_) => const HostDashboardPage()); // Added
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
