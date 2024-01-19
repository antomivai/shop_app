import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  final API_Key = dotenv.env['API_KEY'];
  final _googleAPIHostname = dotenv.env['FIREBASE_AUTH_URL'];
  String _token = '';
  DateTime _expiryDate = DateTime.now();
  String _userId = '';
  Timer? _tokenTimer;

  bool get isAuthenticated {
    return token.isNotEmpty;
  }

  String get token {
    if (_expiryDate.isAfter(DateTime.now()) && !_token.isEmpty) {
      return _token;
    }
    return '';
  }

  String get userId {
    return _userId;
  }

  void setAuthData(String userId, String token, DateTime expiryDate) {
    _userId = userId;
    _token = token;
    _expiryDate = expiryDate;
    _autoLogout();
    notifyListeners();
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = DateTime.now();
    _tokenTimer?.cancel();
    _tokenTimer = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');  //use this to remove a specific key
    prefs.clear(); //user the clear() method to remove all data
  }

  void _autoLogout() {
    _tokenTimer?.cancel();
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _tokenTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final prefData = prefs.getString('userData');
    if (prefData == null) {
      return false;
    }
    final userData = json.decode(prefData) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate'] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = userData['token'].toString();
    _expiryDate = expiryDate;
    _userId = userData['userId '].toString();
    notifyListeners();
    _autoLogout();

    return true;
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> _authenticate(
      String email, String password, String operation) async {
    final url = Uri(
        scheme: 'https',
        host: _googleAPIHostname,
        path: 'v1/accounts:$operation',
        queryParameters: {'key': '$API_Key'});

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      print(responseData);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();

      //Store user's preferences to local device
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }
}
