import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialbunkr_mobile_app/routes/app_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color deepForestGreen = Color(0xFF124734);
    const Color emeraldTint = Color(0xFF1E5942);
    const Color mustardYellow = Color(0xFFE9B949);
    const Color pureWhite = Color(0xFFFFFFFF);
    const Color mutedGray = Color(0xFFD6D6D6);
    const Color lighterGreenButton = Color(0xFF1F664C);
    const Color darkText = Color(0xFF1E1E1E);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [emeraldTint, deepForestGreen],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Subtle background texture (bed icons/bunk patterns)
          Positioned.fill(
            child: CustomPaint(
              painter: BedPatternPainter(Colors.white.withOpacity(0.08)), // White pattern for contrast
            ),
          ),
          // Radial Glow behind logo
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.5 - 100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: mustardYellow.withOpacity(0.3),
                    blurRadius: 80,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: mustardYellow,
                    child: Text(
                      'ஃ',
                      style: GoogleFonts.poppins(
                        fontSize: 60,
                        color: deepForestGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title Text
                  Text(
                    "Welcome to",
                    style: GoogleFonts.poppins(
                      color: pureWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Soc",
                      style: GoogleFonts.poppins(
                        color: pureWhite,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: "i",
                          style: GoogleFonts.poppins(
                            color: mustardYellow,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "al Bunkr",
                          style: GoogleFonts.poppins(
                            color: pureWhite,
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
                      color: mutedGray,
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
                        backgroundColor: lighterGreenButton,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          color: pureWhite,
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
                        backgroundColor: mustardYellow,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black.withOpacity(0.3),
                        // Subtle gradient for premium look
                        // This requires a custom button or a shader mask, keeping it simple for now
                      ),
                      child: Text(
                        "Register",
                        style: GoogleFonts.poppins(
                          color: darkText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Tagline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: mustardYellow, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Join 500+ hosts earning with Social Bunkr",
                        style: GoogleFonts.poppins(
                          color: mutedGray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Footer
          Positioned( // Use Positioned for footer at the bottom
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              "© 2025 Social Bunkr. All rights reserved.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: mutedGray,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter for subtle Ayutha Ezhuthu pattern background
class BedPatternPainter extends CustomPainter {
  final Color color;

  BedPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ஃ',
        style: TextStyle(
          color: color,
          fontSize: 30, // Adjust size as needed
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    const double spacing = 80; // Adjust spacing between logos

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// CustomPainter for the logo (three interlinked circles)
class LogoDotsPainter extends CustomPainter {
  final Color color;

  LogoDotsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final double radius = size.width / 6;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // Draw three interlinked circles (simplified for now)
    canvas.drawCircle(Offset(centerX - radius, centerY - radius / 2), radius, paint);
    canvas.drawCircle(Offset(centerX + radius, centerY - radius / 2), radius, paint);
    canvas.drawCircle(Offset(centerX, centerY + radius / 2), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}