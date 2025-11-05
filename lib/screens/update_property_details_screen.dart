import 'package:flutter/material.dart';
import 'package:socialbunkr_mobile_app/presentation/pages/host_dashboard_page.dart'; // Import color constants

class UpdatePropertyDetailsScreen extends StatelessWidget {
  final String propertyId;

  const UpdatePropertyDetailsScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Property Details', style: TextStyle(color: primaryDarkGreen)),
        backgroundColor: backgroundWhite,
        iconTheme: const IconThemeData(color: primaryDarkGreen), // Back button color
      ),
      body: Center(
        child: Text('Update Property Details for ID: $propertyId'),
      ),
    );
  }
}