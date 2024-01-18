import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    // final orderInfo = Provider.of<Orders>(context);
    // Since we access the Orders provider in line 22 we need to comment line 13 out so that we don't get an infinite loop

    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false).loadOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.error != null) {
                //Do error handling
                return Center(child: Text('An error occurred!'));
              } else {
                return Consumer<Orders>(
                  builder: (context, orderInfo, child) {
                    return ListView.builder(
                      itemCount: orderInfo.orders.length,
                      itemBuilder: (context, index) =>
                          OrderItem(orderInfo.orders[index]),
                    );
                  },
                );
              }
            }
          },
        ));
  }
}
