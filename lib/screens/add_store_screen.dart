import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/store.dart';
import '../providers/stores.dart';
import '../widgets/image_input.dart';
import '../widgets/location_input.dart';

class AddStoreScreen extends StatefulWidget {
  static const routeName = '/add-store';
  const AddStoreScreen({Key? key}) : super(key: key);

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final _titleController = TextEditingController();
  File? _pickedImage;
  GeoLocation? _pickedLocation;

  void _onImageTaken(File image) {
    this._pickedImage = image;
  }

  void _onSelectedLocation(double lat, double lng) {
    _pickedLocation = GeoLocation(latitude: lat, longitude: lng);
  }

  void _saveStore() {
    if (_titleController.text.isEmpty ||
        _pickedImage == null ||
        _pickedLocation == null) {
      return;
    }
    Provider.of<Stores>(context, listen: false)
        .addStore(_titleController.text, _pickedImage!, _pickedLocation!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a New Store'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(labelText: 'Title'),
                    controller: _titleController,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ImageInput(_onImageTaken),
                  SizedBox(
                    height: 10,
                  ),
                  LocationInput(_onSelectedLocation),
                ],
              ),
            ),
          )),
          ElevatedButton.icon(
            onPressed: _saveStore,
            icon: Icon(Icons.add),
            label: Text('Add Store'),
          ),
        ],
      ),
    );
  }
}
