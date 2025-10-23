
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialbunkr_mobile_app/screens/tenant_management/dashboard_screen.dart';
import 'package:socialbunkr_mobile_app/screens/tenant_management/payments_screen.dart';
import 'package:socialbunkr_mobile_app/screens/tenant_management/profile_screen.dart';
import 'package:socialbunkr_mobile_app/screens/tenant_management/tenants_screen.dart';
import 'package:socialbunkr_mobile_app/screens/tenant_management/tickets_screen.dart';

class TenantManagementMainScreen extends StatefulWidget {
  const TenantManagementMainScreen({super.key});

  @override
  State<TenantManagementMainScreen> createState() => _TenantManagementMainScreenState();
}

class _TenantManagementMainScreenState extends State<TenantManagementMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    TenantsScreen(),
    PaymentsScreen(),
    TicketsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Tenants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // This is important for more than 3 items
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0A2540), // Deep Blue
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(),
      ),
    );
  }
}
