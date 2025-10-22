
import 'package:flutter/material.dart';
import 'package:socialbunkr_mobile_app/screens/list_your_room_bed_screen.dart'; // Import the new screen
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 🎨 BRAND COLORS & STYLES
const Color primaryDarkGreen = Color(0xFF0B3D2E);
const Color accentGold = Color(0xFFE9B949);
const Color backgroundWhite = Color(0xFFFFFFFF);
const Color neutralGreenGray = Color(0xFF4C6158);
const Color lightGrayBackground = Color(0xFFF8FAF8);
const Color inactiveTabGray = Color(0xFFEAEDEB);
const Color cardBorderGray = Color(0xFFE8ECE9);
const Color dividerGray = Color(0xFFE0E0E0);
const Color textBlack = Color(0xFF1F1F1F);
const Color textGray = Color(0xFF6C757D);
const BoxShadow cardShadow = BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.08),
  blurRadius: 12,
  offset: Offset(0, 4),
);
const BoxShadow softShadow = BoxShadow(
  color: Color(0x0D000000),
  blurRadius: 10,
  offset: Offset(0, 2),
);

// --- FONT STYLES ---
const String fontName = 'Poppins';

// Booking Model
class Booking {
  final String id;
  final String guestName;
  final String checkIn;
  final String checkOut;
  final String totalPrice;
  final String status; // e.g., Upcoming, Ongoing, Completed, Cancelled

  Booking({
    required this.id,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      guestName: json['guest_name'] ?? 'N/A',
      checkIn: json['checkin'] ?? 'N/A',
      checkOut: json['checkout'] ?? 'N/A',
      totalPrice: '₹${double.tryParse(json['total_price']?.toString() ?? '')?.toStringAsFixed(0) ?? '0'}',
      status: json['status'] ?? 'N/A',
    );
  }
}

class HostDashboardPage extends StatelessWidget {
  final String propertyId;
  const HostDashboardPage({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrayBackground,
      appBar: const HeaderWidget(),
      body: HostDashboardBody(propertyId: propertyId),
    );
  }
}

// 1️⃣ HEADER SECTION
class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundWhite,
      elevation: 0,
      centerTitle: true,
      title: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(
            fontFamily: fontName,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryDarkGreen,
          ),
          children: [
            TextSpan(text: 'Social'),
            TextSpan(
              text: 'Bunkr',
              style: TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: accentGold,
                decorationThickness: 2.0,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: accentGold,
            child: Icon(
              Icons.person_outline,
              color: primaryDarkGreen,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HostDashboardBody extends StatefulWidget {
  final String propertyId;
  const HostDashboardBody({super.key, required this.propertyId});

  @override
  _HostDashboardBodyState createState() => _HostDashboardBodyState();
}

class _HostDashboardBodyState extends State<HostDashboardBody> {
  int _mainTabIndex = 0;
  int _subTabIndex = 0;
  List<Booking> _upcomingBookings = [];
  List<Booking> _ongoingBookings = [];
  bool _isLoadingBookings = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoadingBookings = true;
      _errorMessage = '';
    });

    try {
      // Replace with actual propertyID from user context or selection
      // For now, using a placeholder. You'll need to get this dynamically.
      final String? apiBaseUrl = dotenv.env['API_BASE_URL'];
      final String propertyID = widget.propertyId;
      final _secureStorage = FlutterSecureStorage();
      final token = await _secureStorage.read(key: 'token');
      print('Auth Token: $token'); // Debug print

      if (apiBaseUrl == null) {
        throw Exception('API_BASE_URL is not defined in .env');
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/payments/properties/$propertyID/orders/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _upcomingBookings = (data['Upcoming'] as List)
              .map((e) => Booking.fromJson(e))
              .toList();
          _ongoingBookings = (data['Ongoing'] as List)
              .map((e) => Booking.fromJson(e))
              .toList();
          // You can also parse Completed and Cancelled if needed
        });
      } else {
        _errorMessage =
            'Failed to load bookings: ${response.statusCode} ${response.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching bookings: $e';
    } finally {
      setState(() {
        _isLoadingBookings = false;
      });
    }
  }

  void _onMainTabSelected(int index) {
    setState(() {
      _mainTabIndex = index;
    });
  }

  void _onSubTabSelected(int index) {
    setState(() {
      _subTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        MainTabToggle(
          selectedIndex: _mainTabIndex,
          onTabSelected: _onMainTabSelected,
        ),
        const SizedBox(height: 20),
        // Conditionally show SubTabToggle and its content
        if (_mainTabIndex == 0)
          Expanded(
            child: Column(
              children: [
                SubTabToggle(
                  selectedIndex: _subTabIndex,
                  onTabSelected: _onSubTabSelected,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLoadingBookings
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage.isNotEmpty
                            ? Center(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            : _subTabIndex == 0
                                ? BookingContent(
                                    bookings: _upcomingBookings + _ongoingBookings) // Combine for simplicity
                                : ListVacantBedsContent(propertyId: widget.propertyId),
                  ),
                ),
              ],
            ),
          )
        else
          const Expanded(
            child: Center(
              child: Text(
                "Tenant Management Content",
                style: TextStyle(
                    fontFamily: fontName,
                    fontSize: 16,
                    color: neutralGreenGray),
              ),
            ),
          ),
      ],
    );
  }
}

// 2️⃣ TOP TOGGLE (MAIN TABS)
class MainTabToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const MainTabToggle(
      {super.key, required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: inactiveTabGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTab(context, "List & Earn Extra", 0),
          _buildTab(context, "Tenant Management", 1),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String text, int index) {
    final bool isActive = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? primaryDarkGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontName,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isActive ? Colors.white : primaryDarkGreen,
            ),
          ),
        ),
      ),
    );
  }
}

// 3️⃣ SUB TABS (UNDER MAIN TAB)
class SubTabToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const SubTabToggle(
      {super.key, required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSubTab(context, "Booking", 0),
          const SizedBox(width: 8),
          _buildSubTab(context, "List Vacant Beds", 1),
        ],
      ),
    );
  }

  Widget _buildSubTab(BuildContext context, String text, int index) {
    final bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? primaryDarkGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryDarkGreen,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: fontName,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: isActive ? Colors.white : primaryDarkGreen,
            ),
          ),
        ),
      ),
    );
  }
}

// 4️⃣ BOOKING TAB CONTENT
class BookingContent extends StatelessWidget {
  final List<Booking> bookings;

  const BookingContent({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          'No bookings found.',
          style: TextStyle(fontFamily: fontName, fontSize: 16, color: neutralGreenGray),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(
          guestName: booking.guestName,
          checkIn: booking.checkIn,
          checkOut: booking.checkOut,
          status: booking.status,
        );
      },
    );
  }
}

class BookingCard extends StatelessWidget {
  final String guestName;
  final String checkIn;
  final String checkOut;
  final String status;

  const BookingCard({
    super.key,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [cardShadow],
      ),
      child: Row(
        children: [
          const Icon(Icons.bed_outlined, color: primaryDarkGreen, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guestName,
                  style: const TextStyle(
                    fontFamily: fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryDarkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDateColumn("Check-in", checkIn),
                    Container(
                      height: 30,
                      width: 1,
                      color: dividerGray,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    _buildDateColumn("Check-out", checkOut),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // Handle CHECK-IN action based on booking status
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text(
              "CHECK-IN",
              style: TextStyle(
                fontFamily: fontName,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: fontName,
            fontSize: 12,
            color: textGray,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          date,
          style: const TextStyle(
            fontFamily: fontName,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textBlack,
          ),
        ),
      ],
    );
  }
}

// 5️⃣ LIST VACANT BEDS TAB CONTENT
class ListVacantBedsContent extends StatelessWidget {
  final String propertyId;
  ListVacantBedsContent({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 1,
      childAspectRatio: 3.5,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      mainAxisSpacing: 12,
      children: [
        PropertyActionCard(
          icon: Icons.add_business_outlined,
          title: "List Your Room/Bed",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListYourRoomBedScreen(propertyId: propertyId)),
            );
          },
        ),
        PropertyActionCard(
          icon: Icons.calendar_today_outlined,
          title: "Update Bed/Room Availability",
        ),
        PropertyActionCard(
          icon: Icons.edit_location_alt_outlined,
          title: "Update Property Details",
        ),
      ],
    );
  }
}

class PropertyActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap; // Added onTap callback

  const PropertyActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.onTap, // Added onTap to constructor
  });

  @override
  _PropertyActionCardState createState() => _PropertyActionCardState();
}

class _PropertyActionCardState extends State<PropertyActionCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _scale = 0.97); // Animate on tap
        Future.delayed(const Duration(milliseconds: 150), () {
          setState(() => _scale = 1.0); // Reset scale after animation
          widget.onTap?.call(); // Trigger the actual navigation
        });
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorderGray, width: 1),
            boxShadow: const [softShadow],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: primaryDarkGreen, size: 28),
              const SizedBox(width: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryDarkGreen,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: neutralGreenGray, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
