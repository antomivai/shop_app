import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/chat_screen.dart';
import 'package:flutter_complete_guide/screens/store_detail_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'providers/stores.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';
import 'providers/products_provider.dart';
import 'providers/auth.dart';
import 'screens/add_store_screen.dart';
import 'screens/stores_location_screen.dart';
import 'screens/cart_detail_screen.dart';
import 'screens/order_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_overview_screen.dart';
import 'screens/user_products_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/splash-screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Stores()),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          create: (context) => ProductsProvider(),
          update: (ctx, auth, prevProducts) => prevProducts == null
              ? ProductsProvider()
              : prevProducts.update(auth),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (ctx, auth, prevOrders) =>
              prevOrders == null ? Orders() : prevOrders.update(auth),
        ),
      ],
      child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
                title: 'MyShop',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  hintColor: Colors.deepOrange,
                  fontFamily: 'Lato',
                ),
                home: auth.isAuthenticated
                    ? ProductsOverviewScreen()
                    : FutureBuilder(
                        future: auth.tryAutoLogin(),
                        builder: (ctx, authResultSnapshot) {
                          if (authResultSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SplashScreen();
                          } else {
                            //Here we can check for the authResultSnapshot.data == false then show AuthScreen but that would be redundant
                            //Since tryAutoLogin will notifyListener, the Consumer<Auth) section will be rebuild and the right screen will be shown accordingly.
                            return AuthScreen();
                          }
                        },
                      ),
                routes: {
                  ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                  CartDetailScreen.routeName: (ctx) => CartDetailScreen(),
                  OrderScreen.routeName: (ctx) => OrderScreen(),
                  UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                  EditProductScreen.routeName: (ctx) => EditProductScreen(),
                  StoresLocationScreen.routeName: (ctx) =>
                      StoresLocationScreen(),
                  AddStoreScreen.routeName: (ctx) => AddStoreScreen(),
                  StoreDetailScreen.routeName: (ctx) => StoreDetailScreen(),
                  ChatScreen.routeName: (ctx) => ChatScreen(),
                },
              )),
    );
  }
}
