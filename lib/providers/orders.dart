import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../providers/auth.dart';
import '../providers/cart.dart' show CartItem;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final _firebaseDBHostname = dotenv.env['FIREBASE_REALTIME_DB_URL'];

  late Auth _authenticationData;
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Orders update(Auth auth) {
    _authenticationData = auth;
    return this;
  }

  Future<void> loadOrders() async {
    final url = Uri(
        scheme: 'https',
        host: _firebaseDBHostname,
        path: 'orders/${_authenticationData.userId}.json',
        queryParameters: {
          'auth': _authenticationData.token,
        });

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      List<OrderItem> loadedOrders = [];
      print(response.request.toString());
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: _toCartItemList(
              jsonDecode(orderData['products']) as List<dynamic>),
        ));
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  List<CartItem> _toCartItemList(List<dynamic> list) {
    return list
        .map(
          (item) => CartItem(
            id: item['id'],
            title: item['title'],
            quantity: item['quantity'],
            price: item['price'],
          ),
        )
        .toList();
  }

  Future<void> addOrder(List<CartItem> cartItems, double total) async {
    final url = Uri(
        scheme: 'https',
        host: _firebaseDBHostname,
        path: 'orders/${_authenticationData.userId}.json',
        queryParameters: {'auth': _authenticationData.token});
    final orderTime = DateTime.now();

    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': jsonEncode(cartItems),
            'dateTime': orderTime.toIso8601String(),
          }));

      var res = json.decode(response.body);

      _orders.insert(
        0,
        OrderItem(
            id: res['name'],
            amount: total,
            products: cartItems,
            dateTime: orderTime),
      );
      notifyListeners();
    } catch (error) {
      print('Exception: $error');
    }
  }
}
