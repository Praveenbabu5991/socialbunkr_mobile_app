import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedProperty = "Property 1";
  String selectedFilter = "Upcoming";

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;
    final verticalPadding = isTablet ? 20.0 : 12.0;

    // Colors and fonts
    const Color primaryColor = Color(0xFF0B3D2E);
    const Color accentColor = Color(0xFFF5B400);
    const Color textColor = Color(0xFF1F1F1F);
    const String fontFamily = 'Poppins';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Your Properties",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 22 : 18,
            fontFamily: fontFamily,
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: horizontalPadding),
          child: RichText(
            text: TextSpan(
              text: 'SB',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 22 : 20,
                fontFamily: fontFamily,
                decoration: TextDecoration.underline,
                decorationColor: accentColor,
                decorationThickness: 3,
              ),
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications, color: primaryColor),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Section 1: Add Property Button
              SizedBox(
                width: double.infinity,
                height: isTablet ? 60 : 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Add navigation to Add Property page
                  },
                  child: Text(
                    "+ Add New Property",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 18 : 16,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 28 : 20),

              // ✅ Section 2: Property Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: isTablet ? 4 : 0),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedProperty,
                    items: const [
                      DropdownMenuItem(value: "Property 1", child: Text("Property 1")),
                      DropdownMenuItem(value: "Property 2", child: Text("Property 2")),
                    ],
                    onChanged: (value) {
                      setState(() => selectedProperty = value!);
                    },
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
                    style: TextStyle(
                      color: textColor,
                      fontSize: isTablet ? 18 : 16,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 28 : 24),

              // ✅ Section 3: Booking Filters
              Text(
                "Your Bookings",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 20 : 18,
                  fontFamily: fontFamily,
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ["Upcoming", "Ongoing", "Completed"].map((filter) {
                  final bool isActive = selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(filter),
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : primaryColor,
                      fontSize: isTablet ? 16 : 14,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.w500,
                    ),
                    selected: isActive,
                    onSelected: (_) => setState(() => selectedFilter = filter),
                    selectedColor: primaryColor,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: isTablet ? 28 : 24),

              // ✅ Section 4: Guest Details Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Guest Details",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 20 : 18,
                        fontFamily: fontFamily,
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Row(
                      children: const [
                        Icon(Icons.calendar_today, color: primaryColor, size: 18),
                        SizedBox(width: 8),
                        Text("From: 2025-10-10", style: TextStyle(color: textColor)),
                      ],
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Row(
                      children: const [
                        Icon(Icons.arrow_forward, color: primaryColor, size: 18),
                        SizedBox(width: 8),
                        Text("To: 2025-10-15", style: TextStyle(color: textColor)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 24 : 16),

              // ✅ Section 5: Ad Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: accentColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Boost your visibility — update your property images weekly!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 16 : 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ FOOTER NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        selectedFontSize: isTablet ? 14 : 12,
        unselectedFontSize: isTablet ? 12 : 10,
        iconSize: isTablet ? 28 : 22,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "SB Home"),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: "My Property"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
