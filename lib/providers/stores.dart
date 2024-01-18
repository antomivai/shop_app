import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/helpers/location_helper.dart';

import '../helpers/db_helper.dart';
import '../models/store.dart';

class Stores with ChangeNotifier {
  List<Store> _stores = [];

  List<Store> get stores {
    return [..._stores];
  }

  Store findById(String id) {
    return _stores.firstWhere((store) => store.id == id);
  }

  Future<void> addStore(String title, File image, GeoLocation location) async {
    final address = await LocationHelper.getPlaceAddress(
        location.latitude, location.longitude);
    final updatedLocation = GeoLocation(
        latitude: location.latitude,
        longitude: location.longitude,
        address: address);

    final newStore = Store(
        id: DateTime.now().toString(),
        title: title,
        location: updatedLocation,
        image: image);

    _stores.add(newStore);
    notifyListeners();
    DBHelper.insert('stores', {
      'id': newStore.id,
      'title': newStore.title,
      'image': newStore.image.path,
      'loc_lat': newStore.location.latitude,
      'loc_lng': newStore.location.longitude,
      'address': newStore.location.address,
    });
  }

  Future<void> loadStores() async {
    final dataList = await DBHelper.select('stores');
    _stores = dataList
        .map((store) => Store(
            id: store['id'],
            title: store['title'],
            location: GeoLocation(
                latitude: store['loc_lat'],
                longitude: store['loc_lng'],
                address: store['address']),
            image: File(store['image'])))
        .toList();
    notifyListeners();
  }
}
