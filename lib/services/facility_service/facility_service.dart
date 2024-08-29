
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:user_support_mobile/models/facility_model/facility_model.dart';

class FacilityService {
  final String baseUrl;
  final String authHeader;

  FacilityService({
    required this.baseUrl,
    required this.authHeader,
  });

  Future<Facility?> fetchFacilityData(String code) async {
    final url = '$baseUrl/hfr-adapter/facility-search/$code';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Basic $authHeader',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json.isEmpty) {
        return null;
      } else {
        return Facility.fromJson(json);
      }
    } else {
      return null;
    }
  }
}
