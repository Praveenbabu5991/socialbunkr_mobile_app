import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialbunkr_mobile_app/presentation/widgets/property_card.dart';
import 'package:socialbunkr_mobile_app/routes/app_router.dart';
import '../../logic/blocs/my_properties/my_properties_bloc.dart';
import '../../logic/blocs/my_properties/my_properties_event.dart';

class MyPropertiesTab extends StatelessWidget {
  const MyPropertiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0, bottom: 16.0),
              child: Text(
                "My Properties",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search for a property...",
                        hintStyle: GoogleFonts.poppins(),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      // Handle filter action
                    },
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<MyPropertiesBloc, MyPropertiesState>(
            builder: (context, state) {
              if (state is MyPropertiesLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is MyPropertiesLoaded) {
                if (state.properties.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.home_work_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No properties yet!",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Add your first property to get started.",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.addProperty);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE9B949),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Text(
                              "Add New Property",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: PropertyCard(
                          property: state.properties[index],
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.hostDashboard,
                              arguments: state.properties[index]['id'],
                            );
                          },
                        ),
                      );
                    },
                    childCount: state.properties.length,
                  ),
                );
              }
              if (state is MyPropertiesError) {
                return SliverFillRemaining(
                  child: Center(child: Text(state.error)),
                );
              }
              return const SliverFillRemaining(
                child: Center(child: Text("Something went wrong")),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addProperty).then((_){
            context.read<MyPropertiesBloc>().add(FetchMyProperties());
          });
        },
        backgroundColor: const Color(0xFFE9B949),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
