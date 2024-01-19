import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'auth.dart';
import 'product.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  //TODO: Externalize configuration to firebaseDBHostname
  String _firebaseDBHostname = dotenv.env['FIREBASE_REALTIME_DB_URL'];

  late Auth _authenticationData;

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  ProductsProvider update(Auth authenticationData) {
    _authenticationData = authenticationData;
    return this;
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favorites {
    return _items
        .where(
          (Product prod) => prod.isFavorite,
        )
        .toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> loadProduct() async {
    Uri url = Uri(
        scheme: 'https',
        host: _firebaseDBHostname,
        path: 'products.json',
        queryParameters: {'auth': _authenticationData.token});
    Uri favUrl = Uri(
        scheme: 'https',
        host: _firebaseDBHostname,
        path: 'userFavorites/${_authenticationData.userId}.json',
        queryParameters: {'auth': _authenticationData.token});

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final favoriteResponse = await http.get(favUrl);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    Uri url = Uri(
        scheme: 'https',
        host: _firebaseDBHostname,
        path: 'products.json',
        queryParameters: {'auth': _authenticationData.token});
    //Note: When using firebase, the path products.json indicates to firebase
    //to work with the collection name "products"
    //if the collection does not exist, it will be automatically created.

    try {
      var response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          },
        ),
      );

      var res = json.decode(response.body);
      final newProduct = Product(
          id: res['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri(
          scheme: 'https',
          host: _firebaseDBHostname,
          path: 'products/$id.json',
          queryParameters: {'auth': _authenticationData.token});
      await http.patch(url,
          body: json.encode({
            'title': updatedProduct.title,
            'description': updatedProduct.description,
            'imageUrl': updatedProduct.imageUrl,
            'price': updatedProduct.price,
          }));
      _items[prodIndex] = updatedProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri(
        scheme: 'https',
        host: _firebaseDBHostname,
        path: 'products/$id.json',
        queryParameters: {'auth': _authenticationData.token});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    //Here we perform an optimistic delete which does not wait for the delete fucntion to complete
    //Were went ahead to delete the products in the _items list the the code above then
    //do a rollback later if the delete API call fails.
    //Thus we save the deleted product in the existingProduct so that we can use it to rollback if necessary.
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }

    existingProduct.dispose();
  }
}
