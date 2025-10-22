
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/my_properties/my_properties_bloc.dart';
import '../widgets/property_card.dart';
import '../../routes/app_router.dart';

class MyPropertiesTab extends StatelessWidget {
  const MyPropertiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyPropertiesBloc, MyPropertiesState>(
      builder: (context, state) {
        if (state is MyPropertiesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MyPropertiesLoaded) {
          return ListView.builder(
            itemCount: state.properties.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
          );
        }
        if (state is MyPropertiesError) {
          return Center(child: Text(state.error));
        }
        return Container();
      },
    );
  }
}
