import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/store.dart';

class MapScreen extends StatefulWidget {
  final GeoLocation initialLocation;
  final bool isSelecting;

  MapScreen(
      {this.initialLocation =
          const GeoLocation(latitude: 33.729, longitude: -118.262),
      this.isSelecting = false});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _pickedLocation = LatLng(0, 0);

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Map'),
        actions: <Widget>[
          if (widget.isSelecting)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _pickedLocation.hashCode == LatLng(0, 0).hashCode
                  ? null
                  : () => Navigator.of(context).pop(
                      _pickedLocation), // if user have not pick a location on the map yet then we disable the "check" action
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.initialLocation.latitude,
              widget.initialLocation.longitude),
          zoom: 16,
        ),
        onTap: widget.isSelecting ? _selectLocation : null,
        markers: !_isPickedLocationDefined() && widget.isSelecting
            ? {}
            : {
                Marker(
                    markerId: MarkerId('m1'),
                    position: !_isPickedLocationDefined()
                        ? LatLng(widget.initialLocation.latitude,
                            widget.initialLocation.longitude)
                        : _pickedLocation)
              },
      ),
    );
  }

  bool _isPickedLocationDefined() {
    return _pickedLocation.hashCode != LatLng(0, 0).hashCode;
  }
}
