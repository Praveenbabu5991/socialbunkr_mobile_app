import 'package:flutter/material.dart';

// Color Palette
const Color primaryDarkGreen = Color(0xFF0B3D2E);
const Color primaryLightGreen = Color(0xFF124C3C);
const Color accentGold = Color(0xFFE9B949);
const String fontName = 'Poppins';

class SocialBunkrHeader extends StatelessWidget {
  const SocialBunkrHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryDarkGreen, primaryLightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: accentGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'ஃ',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: primaryDarkGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Titles
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Social Bunkr',
                        style: TextStyle(
                          fontFamily: fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Host Dashboard',
                        style: TextStyle(
                          fontFamily: fontName,
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile Icon
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: primaryDarkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Tagline
            const Text(
              'Manage your bookings, properties, and guests easily.',
              style: TextStyle(
                fontFamily: fontName,
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}