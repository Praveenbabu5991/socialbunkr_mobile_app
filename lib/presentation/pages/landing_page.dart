import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialbunkr_mobile_app/routes/app_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkGreenBackground = Color(0xFF0B3D2E);
    const Color lightGreenTexture = Color(0xFF174C3B);
    const Color accentYellow = Color(0xFFE9B949);
    const Color whiteText = Color(0xFFFFFFFF);
    const Color subtextGray = Color(0xFFD6D6D6);

    return Scaffold(
      backgroundColor: darkGreenBackground,
      body: Stack(
        children: [
          // Subtle background texture (bed icons/bunk patterns)
          Positioned.fill(
            child: CustomPaint(
              painter: BedPatternPainter(lightGreenTexture),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Round yellow logo icon with a bed symbol
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: accentYellow,
                    child: Text(
                      'ஃ',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        color: darkGreenBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title Text
                  Text(
                    "Welcome to",
                    style: GoogleFonts.poppins(
                      color: whiteText,
                      fontSize: 20,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Soc",
                      style: GoogleFonts.poppins(
                        color: whiteText,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: "i",
                          style: GoogleFonts.poppins(
                            color: accentYellow,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "al Bunkr",
                          style: GoogleFonts.poppins(
                            color: whiteText,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle Text
                  Text(
                    "Host management and list vacant beds for extra income.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: subtextGray,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF113E2D), // Darker green for button
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          color: whiteText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.register);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentYellow,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      child: Text(
                        "Register",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Footer (Tagline)
                  Text(
                    "© 2025 Social Bunkr. All rights reserved.",
                    style: GoogleFonts.poppins(
                      color: subtextGray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter for subtle bed pattern background
class BedPatternPainter extends CustomPainter {
  final Color color;

  BedPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.1);
    const double bedSize = 40;
    const double spacing = 60;

    for (double x = 0; x < size.width + bedSize; x += spacing) {
      for (double y = 0; y < size.height + bedSize; y += spacing) {
        // Draw a simple bed shape (rectangle with a headboard)
        canvas.drawRect(Rect.fromLTWH(x, y + bedSize / 4, bedSize, bedSize / 2), paint);
        canvas.drawRect(Rect.fromLTWH(x, y, bedSize / 4, bedSize / 4), paint); // Headboard
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}