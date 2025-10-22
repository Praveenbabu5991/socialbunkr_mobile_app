import 'package:flutter/material.dart';
import 'package:socialbunkr_mobile_app/presentation/pages/add_property_page.dart';
import 'package:socialbunkr_mobile_app/presentation/pages/home_page.dart';
import 'package:socialbunkr_mobile_app/presentation/pages/landing_page.dart';
import 'package:socialbunkr_mobile_app/presentation/pages/login_page.dart';
import 'package:socialbunkr_mobile_app/presentation/pages/register_page.dart';
import 'package:socialbunkr_mobile_app/presentation/pages/verify_property_page.dart';
import 'package:socialbunkr_mobile_app/presentation/pages/property_detail_page.dart';
import 'package:socialbunkr_mobile_app/presentation/pages/host_dashboard_page.dart'; // Added
import 'package:socialbunkr_mobile_app/presentation/pages/host_verification_page.dart'; // Added

class AppRouter {
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String addProperty = '/add-property';
  static const String verifyProperty = '/verify-property';
  static const String propertyDetail = '/property-detail';
  static const String hostDashboard = '/host-dashboard'; // Added
  static const String hostVerification = '/host-verification'; // Added

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
        final propertyId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => HostDashboardPage(propertyId: propertyId));
      case hostVerification: // Added
        return MaterialPageRoute(builder: (_) => const HostVerificationPage()); // Added
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
