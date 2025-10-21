import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/logic/blocs/authentication/authentication_bloc.dart';
import 'package:flutter_application_1/routes/app_router.dart';

class HostDashboardPage extends StatefulWidget {
  const HostDashboardPage({super.key});

  @override
  State<HostDashboardPage> createState() => _HostDashboardPageState();
}

class _HostDashboardPageState extends State<HostDashboardPage> with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _subTabController;

  final Color primaryColor = const Color(0xFF0B3D2E);
  final Color accentColor = const Color(0xFFF5B400);
  final String fontFamily = 'Poppins';

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              children: [
                const TextSpan(text: 'Social '),
                TextSpan(
                  text: 'Bunkr',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: accentColor,
                    decorationThickness: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Text(
                BlocProvider.of<AuthenticationBloc>(context).state is AuthenticationAuthenticated
                    ? (BlocProvider.of<AuthenticationBloc>(context).state as AuthenticationAuthenticated).firstName.isNotEmpty
                        ? (BlocProvider.of<AuthenticationBloc>(context).state as AuthenticationAuthenticated).firstName[0].toUpperCase()
                        : '?'
                    : '?',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _mainTabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: primaryColor,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: primaryColor,
                  tabs: [
                    Tab(
                      child: Text(
                        'List & Earn Extra',
                        style: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Tenant Management',
                        style: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                children: [
                  // Content for "List & Earn Extra"
                  Column(
                    children: [
                      // Sub Tabs
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor),
                          ),
                          child: TabBar(
                            controller: _subTabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: primaryColor,
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: primaryColor,
                            isScrollable: true,
                            tabs: [
                              Tab(
                                child: Text(
                                  'Booking',
                                  style: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'List Vacant Beds',
                                  style: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _subTabController,
                          children: [
                            // Booking Tab Content
                            _buildBookingTabContent(),
                            // My Property Tab Content
                            _buildMyPropertyTabContent(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Content for "Tenant Management" (Placeholder)
                  Center(
                    child: Text(
                      'Tenant Management Content',
                      style: TextStyle(fontFamily: fontFamily, fontSize: 20, color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add new listing/quick action
          Navigator.pushNamed(context, AppRouter.addProperty);
        },
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Assuming 'My Property' is the default active tab
        onTap: (index) {
          // Handle navigation
          if (index == 0) {
            // Navigate to SB Home
            Navigator.pushReplacementNamed(context, AppRouter.home);
          } else if (index == 1) {
            // Stay on My Property (Host Dashboard)
          } else if (index == 2) {
            // Navigate to Profile
            // Navigator.pushReplacementNamed(context, AppRoutes.profile); // Assuming a profile route
          }
        },
        selectedItemColor: primaryColor,
        unselectedItemColor: primaryColor.withOpacity(0.6),
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontFamily: fontFamily),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'SB Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'My Property',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTabContent() {
    // Sample Booking Data
    final List<Map<String, dynamic>> bookings = [
      {
        'guestName': 'John Doe',
        'checkIn': '2025-11-01',
        'checkOut': '2025-11-05',
        'totalPrice': '₹5000',
      },
      {
        'guestName': 'Jane Smith',
        'checkIn': '2025-11-10',
        'checkOut': '2025-11-12',
        'totalPrice': '₹2500',
      },
      {
        'guestName': 'Alice Johnson',
        'checkIn': '2025-11-15',
        'checkOut': '2025-11-20',
        'totalPrice': '₹7000',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['guestName'],
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check-in: ${booking['checkIn']}',
                  style: TextStyle(fontFamily: fontFamily, fontSize: 14),
                ),
                Text(
                  'Check-out: ${booking['checkOut']}',
                  style: TextStyle(fontFamily: fontFamily, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total: ${booking['totalPrice']}',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Handle CHECK-IN action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          'CHECK-IN',
                          style: TextStyle(fontFamily: fontFamily, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyPropertyTabContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Card 1: List Your Room/Bed (Full Width)
          _buildPropertyManagementTile(
            icon: Icons.bed,
            title: 'List Your Room/Bed',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to List Room/Bed')),
              );
              // Navigator.pushNamed(context, AppRouter.addProperty); // Actual navigation
            },
          ),
          const SizedBox(height: 16),
          // Cards 2 & 3: Side-by-side
          Row(
            children: [
              Expanded(
                child: _buildPropertyManagementTile(
                  icon: Icons.calendar_today,
                  title: 'Update Bed/Room Availability',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigating to Update Availability')),
                    );
                    // Handle update availability
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPropertyManagementTile(
                  icon: Icons.edit,
                  title: 'Update Property Details',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigating to Update Property Details')),
                    );
                    // Handle update property details
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyManagementTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: primaryColor, size: 30),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: primaryColor.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}