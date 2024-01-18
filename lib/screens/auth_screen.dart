import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/avatar_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 64.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          // color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  File? _avatarImg;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 3000,
      ),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.fastOutSlowIn));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: Curves.fastEaseInToSlowEaseOut));
  }

  void _avatarImgReceiver(File? avatarImg) {
    _avatarImg = avatarImg;
  }

  Future<void> _submit() async {
    if (_avatarImg == null && _authMode == AuthMode.Signup) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please take a photo for your avatar.'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }

    var isvalid = _formKey.currentState?.validate();
    if (isvalid == null || !isvalid) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    final auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential;
      if (_authMode == AuthMode.Login) {
        // Log user in
        userCredential = await auth.signInWithEmailAndPassword(
            email: _authData['email']!, password: _authData['password']!);

        // Since we are using the Firebase SDK to manage Authentication, there is no need to call the RESTful Authentication API below
        // await Provider.of<Auth>(context, listen: false)
        //     .signin(_authData['email']!, _authData['password']!);
      } else {
        // Sign user up
        userCredential = await auth.createUserWithEmailAndPassword(
            email: _authData['email']!, password: _authData['password']!);

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_avatar')
            .child(userCredential.user!.uid + '.jpg');

        await ref.putFile(_avatarImg!).whenComplete(() => null);

        final avatar_url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({'email:': _authData['email'], 'avatar_url': avatar_url});

        // Since we are using the Firebase SDK to manage Authentication, there is no need to call the RESTful Authentication API below
        // await Provider.of<Auth>(context, listen: false)
        //     .signup(_authData['email']!, _authData['password']!);
      }
      IdTokenResult tokenResult = await auth.currentUser!.getIdTokenResult();

      // Ideally the rest of the app should depend on the FirebaseAuth.instance to determine Authentication.
      // However since the rest of the app was wired to use the Auth provider, we set the Auth provider here
      // with authentication data taken from the FirebaseAuth.instance
      Provider.of<Auth>(context, listen: false).setAuthData(
          userCredential.user!.uid,
          tokenResult.token!,
          tokenResult
              .expirationTime!); //TODO: need to check that token is not null
    } on HttpException catch (error) {
      var errorMsg = 'Authentication Failed.';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMsg = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMsg = 'Please enter a valid email.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMsg = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMsg = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMsg = 'Invalid password.';
      }
      _showErrorDialog(errorMsg);
    } catch (error) {
      var errorMsg = 'Could not authenticate. Please try again later.';
      _showErrorDialog(errorMsg);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An Error Occurred!'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: Text('Okay'),
                  onPressed: () => Navigator.of(ctx).pop(),
                )
              ],
            ));
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 3000),
        curve: Curves.fastEaseInToSlowEaseOut,
        height: _authMode == AuthMode.Signup ? 400 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 400 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (_authMode == AuthMode.Signup)
                  AvatarPicker(_avatarImgReceiver),
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value != null ? value : '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value != null ? value : '';
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(30),
                    // ),
                    // padding:
                    //     EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    // color: Theme.of(context).primaryColor,
                    // textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  // padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
