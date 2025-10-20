
import 'package:flutter/material.dart';

class PropertyDetailPage extends StatelessWidget {
  final String propertyId;

  const PropertyDetailPage({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0B3D2E);
    const String fontFamily = 'Poppins';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details', style: TextStyle(fontFamily: fontFamily, color: primaryColor)),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Property ID: ${propertyId}',
              style: const TextStyle(fontSize: 20, fontFamily: fontFamily, color: primaryColor),
            ),
            const SizedBox(height: 20),
            const Text(
              '(Details of the property will be displayed here)',
              style: TextStyle(fontSize: 16, fontFamily: fontFamily, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
