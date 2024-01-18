import 'dart:convert';

import 'package:http/http.dart' as http;

const GOOGLE_API_KEY = 'AIzaSyAYuoWiohtvTjoIwuzXKtlGT3i1JJC2KeE';

class LocationHelper {
  static String generateLocationPreviewImage({
    double latitude = 0,
    double longitude = 0,
  }) {
    //TODO: Add signature to request for additional security
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  static Future<String> getPlaceAddress(
      double latitude, double longitude) async {
    const googleMapHost = 'maps.googleapis.com';
    final url = Uri(
        scheme: 'https',
        host: googleMapHost,
        path: 'maps/api/geocode/json',
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': '$GOOGLE_API_KEY'
        });

    final response = await http.get(url);
    return json.decode(response.body)['results'][0]['formatted_address'];
  }
}
