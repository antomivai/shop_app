import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/store_detail_screen.dart';
import '../screens/add_store_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/stores.dart';

class StoresLocationScreen extends StatelessWidget {
  const StoresLocationScreen({Key? key}) : super(key: key);
  static const routeName = '/stores';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stores Location'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AddStoreScreen.routeName);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Stores>(context, listen: false).loadStores(),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<Stores>(
                child: Center(child: Text('No stores in your specified area.')),
                builder: (ctx, stores, ch) => stores.stores.length <= 0
                    ? ch!
                    : ListView.builder(
                        itemCount: stores.stores.length,
                        itemBuilder: (ctx, i) => ListTile(
                          leading: CircleAvatar(
                              backgroundImage:
                                  FileImage(stores.stores[i].image)),
                          title: Text(stores.stores[i].title),
                          subtitle: Text(stores.stores[i].location.address),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                StoreDetailScreen.routeName,
                                arguments: stores.stores[i].id);
                          },
                        ),
                      ),
              ),
      ),
    );
  }
}
