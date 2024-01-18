import 'dart:io';

class GeoLocation {
  final double latitude;
  final double longitude;
  final String address;

  const GeoLocation(
      {required this.latitude, required this.longitude, this.address = ''});
}

class Store {
  final String id;
  final String title;
  final GeoLocation location;
  final File image;

  Store(
      {required this.id,
      required this.title,
      required this.location,
      required this.image});
}
