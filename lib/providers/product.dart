import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final _firebaseDBHostname =
        'shop-app-learning-8f9ce-default-rtdb.firebaseio.com';
    final url = Uri(
        scheme: 'https',
        host: _firebaseDBHostname,
        path: 'userFavorites/$userId/$id.json',
        queryParameters: {'auth': token});

    isFavorite = !isFavorite;
    notifyListeners();

    final response = await http.put(url, body: json.encode(isFavorite));
    if (response.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpException('Unable to update favorite.');
    }
  }
}
