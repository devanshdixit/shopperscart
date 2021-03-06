import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shopperscart/app/app.logger.dart';
import 'package:stacked/stacked.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

class BackMapViewModel extends BaseViewModel {
  final log = getLogger('BackMapViewModel');
  Set<Marker> markers = Set<Marker>();
  bool maploading = true;

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  LatLng getRandomLocation(LatLng point, int radius) {
    //This is to generate 10 random points
    double x0 = point.latitude;
    double y0 = point.longitude;

    Random random = new Random();

    // Convert radius from meters to degrees
    double radiusInDegrees = radius / 111000;

    double u = random.nextDouble();
    double v = random.nextDouble();
    double w = radiusInDegrees * sqrt(u);
    double t = 2 * pi * v;
    double x = w * cos(t);
    double y = w * sin(t) * 1.75;

    // Adjust the x-coordinate for the shrinking of the east-west distances
    double newX = x / sin(y0);

    double foundLatitude = newX + x0;
    double foundLongitude = y + y0;
    LatLng randomLatLng = new LatLng(foundLatitude, foundLongitude);
    return randomLatLng;
  }

  updatePinOnMap(
      {required LatLng location,
      required Completer<GoogleMapController> completer}) async {
    CameraPosition cPosition = CameraPosition(
      zoom: 10,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(location.latitude, location.longitude),
    );
    final GoogleMapController controller = await completer.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    log.d('databse updaeted');
  }

  void onMapCreated(GoogleMapController controller,
      Completer<GoogleMapController> _controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }
  }
}
