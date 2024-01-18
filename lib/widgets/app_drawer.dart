import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/chat_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/user_products_screen.dart';
import '../screens/order_screen.dart';
import '../screens/stores_location_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: <Widget>[
        AppBar(
          title: Text('Hello Friend'),
          automaticallyImplyLeading: false,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.shop),
          title: Text('Shop'),
          onTap: () => Navigator.of(context).pushReplacementNamed('/'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.store),
          title: Text('Stores'),
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(StoresLocationScreen.routeName),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.payment),
          title: Text('Orders'),
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(OrderScreen.routeName),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.support_agent),
          title: Text('Chat Support'),
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(ChatScreen.routeName),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage Products'),
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(UserProductsScreen.routeName),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(
                '/'); // This navigate to the home screen which will ensure that we ended up on the Authentication Screen.
            Provider.of<Auth>(context, listen: false).logout();
            FirebaseAuth.instance.signOut();
          },
        ),
      ]),
    );
  }
}
