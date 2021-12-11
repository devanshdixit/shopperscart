import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:places_service/places_service.dart';
import 'package:shopperscart/app/app.locator.dart';
import 'package:shopperscart/app/app.logger.dart';
import 'package:shopperscart/services/distance.dart';
import 'package:shopperscart/services/location_service.dart';
import 'package:shopperscart/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddressSelectionViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _locationService = locator<LocationService>();
  final _placesService = locator<PlacesService>();
  final _userService = locator<UserService>();
  TextEditingController currentText = TextEditingController();
  TextEditingController destinationText = TextEditingController();
  TextEditingController stop1Text = TextEditingController();
  TextEditingController stop2Text = TextEditingController();
  FocusNode currentFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();
  FocusNode stop1FocusNode = FocusNode();
  FocusNode stop2FocusNode = FocusNode();
  bool isDest = true, isCurr = false;
  String scheduledDate = '', scheduledTime = '';
  String currentPlaceId = '',
      destinationPlaceId = '',
      stop1PlaceId = '',
      stop2PlaceId = '';
  Position? currentPosition;
  String placeRates = '',
      placeDistances = '',
      duration = '',
      rate = '',
      bookingType = '';
  final log = getLogger('CarBookingViewModel');
  late LatLng loc1, loc2, stop1loc3, stop2loc4;
  List<PlacesAutoCompleteResult> _autoCompleteResults = [];
  List<PlacesAutoCompleteResult> get autoCompleteResults =>
      _autoCompleteResults;

  bool get hasAutoCompleteResults => _autoCompleteResults.isNotEmpty;
  double stopCounter = 0, appBarHeight = 150;
  bool stop1 = false, stop2 = false;

  Future<void> _getAutoCompleteResults() async {
    if (destinationFocusNode.hasFocus) {
      if (destinationText.value.text != '') {
        final placesResults =
            await _placesService.getAutoComplete(destinationText.value.text);
        _autoCompleteResults = placesResults;
        notifyListeners();
      }
    }
    if (stop1FocusNode.hasFocus) {
      if (stop1Text.value.text != '') {
        final placesResults =
            await _placesService.getAutoComplete(stop1Text.value.text);
        _autoCompleteResults = placesResults;
        notifyListeners();
      }
    }
    if (stop2FocusNode.hasFocus) {
      if (stop2Text.value.text != '') {
        final placesResults =
            await _placesService.getAutoComplete(stop2Text.value.text);
        _autoCompleteResults = placesResults;
        notifyListeners();
      }
    }
    if (currentFocusNode.hasFocus) {
      if (currentText.value.text != '') {
        final placesResults =
            await _placesService.getAutoComplete(currentText.value.text);
        _autoCompleteResults = placesResults;
        notifyListeners();
      }
    }
  }

  void setLocOnChange() async {
    await getCurrentLocation();
    var googleGeocoding = GoogleGeocoding(
      'AIzaSyBGp2Pnbz9Htx-jMVQPXXES7t0iA4tQwTw',
    );
    var risult = await googleGeocoding.geocoding.getReverse(
      LatLon(
        currentPosition!.latitude,
        currentPosition!.longitude,
      ),
    );
    if (risult != null) {
      GeocodingResult re = risult.results![0];
      currentPlaceId = re.placeId!;
      currentText.text = re.formattedAddress!;
      notifyListeners();
    }
  }

  void useCurrentLoc() async {
    setBusy(true);
    _placesService.initialize(
      apiKey: 'AIzaSyBGp2Pnbz9Htx-jMVQPXXES7t0iA4tQwTw',
    );
    await getCurrentLocation();
    var googleGeocoding = GoogleGeocoding(
      'AIzaSyBGp2Pnbz9Htx-jMVQPXXES7t0iA4tQwTw',
    );
    var risult = await googleGeocoding.geocoding.getReverse(
      LatLon(
        currentPosition!.latitude,
        currentPosition!.longitude,
      ),
    );
    if (risult != null) {
      GeocodingResult re = risult.results![0];
      if (currentFocusNode.hasFocus) {
        currentPlaceId = re.placeId!;
        currentText.text = re.formattedAddress!;
      } else if (destinationFocusNode.hasFocus) {
        destinationPlaceId = re.placeId!;
        destinationText.text = re.formattedAddress!;
      } else if (stop1FocusNode.hasFocus) {
        stop1PlaceId = re.placeId!;
        stop1Text.text = re.formattedAddress!;
      } else if (stop2FocusNode.hasFocus) {
        stop2PlaceId = re.placeId!;
        stop2Text.text = re.formattedAddress!;
      }
      notifyListeners();
    }
    setBusy(false);
  }

  void setCurrentLoc() async {
    setBusy(true);
    _placesService.initialize(
      apiKey: 'AIzaSyBGp2Pnbz9Htx-jMVQPXXES7t0iA4tQwTw',
    );
    await getCurrentLocation();
    var googleGeocoding = GoogleGeocoding(
      'AIzaSyBGp2Pnbz9Htx-jMVQPXXES7t0iA4tQwTw',
    );
    var risult = await googleGeocoding.geocoding.getReverse(
      LatLon(
        currentPosition!.latitude,
        currentPosition!.longitude,
      ),
    );
    if (risult != null) {
      GeocodingResult re = risult.results![0];
      currentPlaceId = re.placeId!;
      currentText.text = re.formattedAddress!;
      notifyListeners();
    }
    setBusy(true);

    currentText.addListener(() {
      if (currentFocusNode.hasFocus) {
        _getAutoCompleteResults();
      }
    });

    currentFocusNode.addListener(() {
      autoCompleteResults.clear();
      notifyListeners();
    });

    setBusy(false);
  }

  getCurrentLocation() async {
    if (await Permission.location.request().isGranted) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) async {
        currentPosition = Position(
            longitude: position.longitude,
            latitude: position.latitude,
            timestamp: position.timestamp,
            accuracy: position.accuracy,
            altitude: position.altitude,
            heading: position.heading,
            speed: position.speed,
            speedAccuracy: position.speedAccuracy);
      }).catchError((e) {
        throw Exception(e);
      });
      return currentPosition;
    }
  }

  void selectFromMap() {
    // _navigationService.navigateToView(PlacePicker(
    //   apiKey: 'AIzaSyBGp2Pnbz9Htx-jMVQPXXES7t0iA4tQwTw',
    //   initialPosition: LatLng(_locationService.currentLocation.latitude,
    //       _locationService.currentLocation.longitude),
    //   useCurrentLocation: true,
    //   selectInitialPosition: true,
    //   onPlacePicked: (result) {
    //     if (currentFocusNode.hasFocus) {
    //       currentText.text = result.formattedAddress!;
    //       currentPlaceId = result.placeId!;
    //     } else if (stop1FocusNode.hasFocus) {
    //       stop1Text.text = result.formattedAddress!;
    //       stop1PlaceId = result.placeId!;
    //     } else if (stop2FocusNode.hasFocus) {
    //       stop2Text.text = result.formattedAddress!;
    //       stop2PlaceId = result.placeId!;
    //     } else {
    //       destinationText.text = result.formattedAddress!;
    //       destinationPlaceId = result.placeId!;
    //     }
    //     _navigationService.back();
    //     notifyListeners();
    //     getCoordinates();
    //   },
    // ));
  }

  void setSearchAdddress(String address, String placeId) async {
    if (destinationFocusNode.hasFocus) {
      destinationPlaceId = placeId;
      destinationText.text = address;
    }
    if (currentFocusNode.hasFocus) {
      currentPlaceId = placeId;
      currentText.text = address;
      currentFocusNode.nextFocus();
    }
    if (stop1FocusNode.hasFocus) {
      stop1PlaceId = placeId;
      stop1Text.text = address;
      stop1FocusNode.nextFocus();
    }
    if (stop2FocusNode.hasFocus) {
      stop2PlaceId = placeId;
      stop2Text.text = address;
      stop2FocusNode.nextFocus();
    }
    stop1FocusNode.unfocus();
    stop2FocusNode.unfocus();
    destinationFocusNode.unfocus();
    currentFocusNode.unfocus();
    autoCompleteResults.clear();

    getCoordinates();
    notifyListeners();
  }

  void getCoordinates() async {
    if (currentPlaceId != '' &&
        destinationPlaceId != '' &&
        stop1PlaceId != '' &&
        stop2PlaceId == '') {
      await _placesService.getPlaceDetails(currentPlaceId).then((value) {
        loc1 = LatLng(value.lat!, value.lng!);
      });
      await _placesService.getPlaceDetails(destinationPlaceId).then((value) {
        loc2 = LatLng(value.lat!, value.lng!);
      });
      await _placesService.getPlaceDetails(stop1PlaceId).then((value) {
        stop1loc3 = LatLng(value.lat!, value.lng!);
      });
      await saveData();
      // _navigationService.navigateToView(CarSelectionMapView(
      //   bookingtype: bookingType,
      //   end: loc2,
      //   start: loc1,
      // ));
    } else if (currentPlaceId != '' &&
        destinationPlaceId != '' &&
        stop1PlaceId != '' &&
        stop2PlaceId != '') {
      await _placesService.getPlaceDetails(currentPlaceId).then((value) {
        loc1 = LatLng(value.lat!, value.lng!);
      });
      await _placesService.getPlaceDetails(destinationPlaceId).then((value) {
        loc2 = LatLng(value.lat!, value.lng!);
      });
      await _placesService.getPlaceDetails(stop1PlaceId).then((value) {
        stop1loc3 = LatLng(value.lat!, value.lng!);
      });
      await _placesService.getPlaceDetails(stop2PlaceId).then((value) {
        stop2loc4 = LatLng(value.lat!, value.lng!);
      });
      await saveData();
      // _navigationService.navigateToView(CarSelectionMapView(
      //   bookingtype: bookingType,
      //   end: loc2,
      //   start: loc1,
      // ));
    } else if (currentPlaceId != '' && destinationPlaceId != '') {
      await _placesService.getPlaceDetails(currentPlaceId).then((value) {
        loc1 = LatLng(value.lat!, value.lng!);
      });
      await _placesService.getPlaceDetails(destinationPlaceId).then((value) {
        loc2 = LatLng(value.lat!, value.lng!);
      });

      await saveData();
      //   if (type == DeliveryService) {
      //     return _navigationService.navigateToView(DeliveryTypeSelection(
      //       en: loc2,
      //       st: loc1,
      //     ));
      //   } else {
      //     return _navigationService.navigateToView(CarSelectionMapView(
      //       bookingtype: bookingType,
      //       end: loc2,
      //       start: loc1,
      //     ));
      //   }
    }
  }

  void runDispose() {
    autoCompleteResults.clear();
    currentText.dispose();
    destinationText.dispose();
    currentFocusNode.dispose();
    destinationFocusNode.dispose();
    stop1Text.dispose();
    stop1FocusNode.dispose();
    stop2Text.dispose();
    stop2FocusNode.dispose();
  }

  Future<void> saveData() async {
    final currentUser = _userService.currentUser;
    await Calculate()
        .calculateDistan(
      dropoffplac1: loc2.latitude,
      dropoffplac2: loc2.longitude,
      selectedPlac1: loc1.latitude,
      selectedPlac2: loc1.longitude,
      formtype: 'Cartype',
    )
        .then((value) {
      placeDistances = value['distance'];
      placeRates = value['placeRate'].toString();
      duration = value['duration'];
      rate = value['rate'].toString();
    });
    Map<String, dynamic> result = stop1Text.text != ''
        ? {
            'startLocation': currentText.text,
            'destination': destinationText.text,
            'stop1Location': stop1Text.text,
            'scheduleTime': scheduledTime,
            'scheduledDate': scheduledDate,
            'userId': currentUser.id,
            'price': placeRates,
            'distace': placeDistances,
            'paymentStatus': 'Confirmed',
            'drivers': null,
            'selectedPlace': [
              loc1.latitude,
              loc1.longitude,
            ],
            'stop1Place': [
              stop1loc3.latitude,
              stop1loc3.longitude,
            ],
            'dropoffplace': [loc2.latitude, loc2.longitude],
            'rideType': bookingType,
            'pushToken': currentUser.pushToken,
          }
        : stop2Text.text != ''
            ? {
                'startLocation': currentText.text,
                'destination': destinationText.text,
                'stop1Location': stop1Text.text,
                'stop2Location': stop2Text.text,
                'scheduleTime': scheduledTime,
                'scheduledDate': scheduledDate,
                'userId': currentUser.id,
                'price': placeRates,
                'distace': placeDistances,
                'paymentStatus': 'Confirmed',
                'drivers': null,
                'selectedPlace': [
                  loc1.latitude,
                  loc1.longitude,
                ],
                'stop1Place': [
                  stop1loc3.latitude,
                  stop1loc3.longitude,
                ],
                'stop2Place': [
                  stop2loc4.latitude,
                  stop2loc4.longitude,
                ],
                'dropoffplace': [
                  loc2.latitude,
                  loc2.longitude,
                ],
                'rideType': bookingType,
                'pushToken': currentUser.pushToken,
              }
            : {
                'startLocation': currentText.text,
                'destination': destinationText.text,
                'scheduleTime': scheduledTime,
                'scheduledDate': scheduledDate,
                'userId': currentUser.id,
                'price': placeRates,
                'distace': placeDistances,
                'paymentStatus': 'Confirmed',
                'drivers': null,
                'selectedPlace': [
                  loc1.latitude,
                  loc1.longitude,
                ],
                'PaymentType': 'Cash',
                'dropoffplace': [
                  loc2.latitude,
                  loc2.longitude,
                ],
                'rideType': bookingType,
                'pushToken': currentUser.pushToken,
              };
  }

  void setAddStop(double count) {
    if (count == 0) {
      stop1 = true;
      stopCounter = 1;
      appBarHeight = appBarHeight + 80;
    }
    if (count == 1) {
      stop2 = true;
      stopCounter = 2;
      appBarHeight = appBarHeight + 80;
    }
    notifyListeners();
  }

  void removeStop() {
    if (stopCounter == 1) {
      stop1 = false;
      stopCounter = 0;
      appBarHeight = appBarHeight - 80;
    }
    if (stopCounter == 2) {
      stop2 = false;
      stopCounter = 1;
      appBarHeight = appBarHeight - 80;
    }
    notifyListeners();
  }

  void setAirport(LatLng latLng, String text) async {
    final place = _placesService.getAutoComplete(text);
    await place.then((value) {
      PlacesAutoCompleteResult placesAutoCompleteResult = value[0];
      destinationPlaceId = placesAutoCompleteResult.placeId!;
      destinationText.text = placesAutoCompleteResult.mainText!;
    });
    loc2 = latLng;
    notifyListeners();
    await _placesService.getPlaceDetails(currentPlaceId).then((value) {
      loc1 = LatLng(value.lat!, value.lng!);
    });
    await saveData();
    // _navigationService.navigateToView(CarSelectionMapView(
    //   bookingtype: bookingType,
    //   end: loc2,
    //   start: loc1,
    // ));
  }
}