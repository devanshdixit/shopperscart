import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shopperscart/app/app.locator.dart';
import 'package:shopperscart/services/distance.dart';
import 'package:shopperscart/ui/Maps/back_map_viewmodel.dart';
import 'package:shopperscart/ui/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BackMap extends StatefulWidget {
  final Function() onLocationChange;
  BackMap({Key? key, required this.onLocationChange}) : super(key: key);
  @override
  _BackMapState createState() => _BackMapState();
}

class _BackMapState extends State<BackMap> {
  Completer<GoogleMapController> _controller = Completer();

  final calculate = locator<Calculate>();

  late Location location;

  late CameraPosition initialLocation;

  late LatLng currentLocation;

  late StreamSubscription<LocationData> locationData;

  @override
  void initState() {
    currentLocation = LatLng(calculate.currentPosition.latitude,
        calculate.currentPosition.longitude);
    initialLocation = CameraPosition(
      zoom: 10,
      bearing: CAMERA_BEARING,
      tilt: CAMERA_TILT,
      target: currentLocation,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BackMapViewModel>.reactive(
      onModelReady: (model) {
        location = new Location();
        locationData =
            location.onLocationChanged.listen((LocationData? cLoc) async {
          if (cLoc != null) {
            final distance = model.calculateDistance(currentLocation.latitude,
                currentLocation.longitude, cLoc.latitude, cLoc.longitude);
            if (distance > 1.0) {
              setState(() {
                currentLocation = LatLng(cLoc.latitude!, cLoc.longitude!);
              });
              model.updatePinOnMap(
                location: currentLocation,
                completer: _controller,
              );
              widget.onLocationChange();
            }
          }
        });
      },
      onDispose: (model) {
        locationData.cancel();
      },
      builder: (context, model, child) {
        return model.maploading
            ? LoadingScrren()
            : GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: false,
                mapType: MapType.normal,
                markers: model.markers,
                initialCameraPosition: initialLocation,
                onMapCreated: (controller) {
                  model.onMapCreated(controller, _controller);
                },
              );
      },
      viewModelBuilder: () => BackMapViewModel(),
    );
  }
}
