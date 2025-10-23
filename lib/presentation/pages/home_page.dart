import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/authentication/authentication_bloc.dart';
import '../../logic/blocs/my_properties/my_properties_bloc.dart';
import '../../data/repositories/property_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../tabs/my_properties_tab.dart';
import '../../routes/app_router.dart';
import 'package:socialbunkr_mobile_app/presentation/widgets/custom_button.dart'; // Added for "Verify Account" button
import '../../logic/blocs/my_properties/my_properties_event.dart'; // Added
import 'package:socialbunkr_mobile_app/presentation/widgets/social_bunkr_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyPropertiesBloc(propertyRepository: PropertyRepository(), userRepository: UserRepository())..add(FetchMyProperties()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    MyPropertiesTab(),
    ProfileTab(), // Assuming you have a ProfileTab widget
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
            icon: Icon(Icons.home),
            label: 'SB Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'My Property',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? selectedProperty;
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SocialBunkrHeader(),
            // The rest of the page content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    builder: (context, state) {
                      bool isVerified = false;
                      if (state is AuthenticationAuthenticated) {
                        isVerified = state.isVerified;
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Added to align children
                        children: [
                          if (!isVerified)
                            Card(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              color: primaryColor.withOpacity(0.1),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Verify Your Account',
                                      style: TextStyle(
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'To list properties and manage bookings, please verify your account.',
                                      style: TextStyle(fontFamily: fontFamily, fontSize: 14, color: primaryColor.withOpacity(0.8)),
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, AppRouter.hostVerification);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        ),
                                        child: Text(
                                          'Verify Now',
                                          style: TextStyle(fontFamily: fontFamily, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(height: isTablet ? 28 : 20), // Spacing after verify button/card
                          // Add New Property Button (conditionally enabled)
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
                              onPressed: isVerified // Only enable if verified
                                  ? () {
                                      Navigator.pushNamed(context, '/add-property');
                                    }
                                  : () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please verify your account to add a new property.')),
                                      );
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
                        ],
                      );
                    },
                  ),

                  SizedBox(height: isTablet ? 28 : 20),

                  // ✅ Section 2: Property Dropdown
                  BlocBuilder<MyPropertiesBloc, MyPropertiesState>(
                    builder: (context, state) {
                      if (state is MyPropertiesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is MyPropertiesLoaded) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: isTablet ? 4 : 0),
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedProperty ?? (state.properties.isNotEmpty ? state.properties.first['id'] : null),
                              items: state.properties.map<DropdownMenuItem<String>>((property) {
                                return DropdownMenuItem<String>(
                                  value: property['id'],
                                  child: Text(property['name']),
                                );
                              }).toList(),
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
                        );
                      }
                      if (state is MyPropertiesError) {
                        return Text(state.error);
                      }
                      return Container();
                    },
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
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Tab'),
    );
  }
}
