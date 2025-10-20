
import 'package:image_picker/image_picker.dart';

import '../providers/property_api_provider.dart';

class PropertyRepository {
  final PropertyApiProvider _propertyApiProvider = PropertyApiProvider();

  Future<Map<String, dynamic>> addProperty(Map<String, dynamic> propertyData) {
    return _propertyApiProvider.addProperty(propertyData);
  }

  Future<List<dynamic>> getMyProperties(String organizationId) {
    return _propertyApiProvider.getMyProperties(organizationId);
  }

  Future<void> verifyProperty(String propertyId, String documentType, XFile document) {
    return _propertyApiProvider.verifyProperty(propertyId, documentType, document);
  }
}
