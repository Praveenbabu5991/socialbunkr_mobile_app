
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../logic/blocs/authentication/authentication_bloc.dart';
import '../../logic/blocs/my_properties/my_properties_bloc.dart';
import '../../logic/blocs/my_properties/my_properties_event.dart';
import '../../routes/app_router.dart'; // Added

class PropertyCard extends StatelessWidget {
  final dynamic property;

  const PropertyCard({super.key, required this.property, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0B3D2E);
    const Color accentColor = Color(0xFFF5B400);
    const String fontFamily = 'Poppins';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap, // Use the provided onTap callback
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image
            Builder(
              builder: (context) {
                final String apiBaseUrl = kIsWeb ? dotenv.env['API_BASE_URL_WEB']! : dotenv.env['API_BASE_URL_ANDROID']!;
                String imageUrl = '';
                if (property['images'] != null && (property['images'] as List).isNotEmpty) {
                  imageUrl = property['images'][0]['image'];
                  if (!imageUrl.startsWith('http')) {
                    imageUrl = '$apiBaseUrl$imageUrl';
                  }
                }

                return (imageUrl.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                            ),
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    );
              }
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['name'],
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property['location']['street_address'],
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (property['is_verified'] == false)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(context, AppRouter.verifyProperty, arguments: property['id']);
                        if (result == true) {
                          // Refresh the properties list
                          context.read<MyPropertiesBloc>().add(FetchMyProperties());
                        }
                      },
                      child: Text(
                        'Verify',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
