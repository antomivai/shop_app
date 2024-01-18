import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/map_screen.dart';
import 'package:provider/provider.dart';

import '../providers/stores.dart';

class StoreDetailScreen extends StatelessWidget {
  const StoreDetailScreen({Key? key}) : super(key: key);
  static const routeName = '/store-detail';

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String;
    final selectedStore =
        Provider.of<Stores>(context, listen: false).findById(id);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedStore.title),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 250,
            width: double.infinity,
            child: Image.file(
              selectedStore.image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            selectedStore.location.address,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          SizedBox(
            height: 10,
          ),
          TextButton(
            child: Text('View on Map'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) =>
                    MapScreen(initialLocation: selectedStore.location))),
          ),
        ],
      ),
    );
  }
}
