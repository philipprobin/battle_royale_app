import 'dart:async';

import 'package:flutter/material.dart';
import 'package:real_life_battle_royale/components/location_item.dart';
import 'package:real_life_battle_royale/realm/schemas.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import "package:real_life_battle_royale/realm/schemas.dart";
import 'package:real_life_battle_royale/screens/create_room_screen.dart';
import 'package:realm/realm.dart';
import '../components/todo_item.dart';
import '../components/widgets.dart';
import '../realm/realm_services.dart';

class MapScreen extends StatefulWidget {
  static String routeName = '/map';

  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _isCreated = false;
  bool _firstMovement = false;
  late Location locations;

  late StreamSubscription<Position> _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((position) {
      LatLng latLng = LatLng(position.latitude, position.longitude);
      debugPrint("position ${position.longitude} / ${position.latitude}");

      var realmServices = Provider.of<RealmServices>(context, listen: false);
      if (_isCreated) {
        if(!_firstMovement && _controller != null){
          _moveCameraToLocation(latLng);
        }
        updatePos(
            realmServices, context, position.latitude, position.longitude);
      } else {
        if (_controller != null) {
          _moveCameraToLocation(latLng);
        }
        createPos(
            realmServices, context, position.latitude, position.longitude);
      }
    });
  }

  void _moveCameraToLocation(LatLng latLng) {
    _firstMovement = true;
    _controller!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: latLng,
        zoom: 15,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final realmServices = Provider.of<RealmServices>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.meeting_room),
            tooltip: '',
            onPressed: () => Navigator.pushNamed(context, CreateRoomScreen.routeName),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
            },
            onLongPress: _onMapLongPressed,
            initialCameraPosition: const CameraPosition(
              target: LatLng(11.4924948, 7.4166957),
              zoom: 11.0,
            ),
            markers: _markers,
            circles: _circles,
            myLocationEnabled: true,
          ),
          Container(
            height: 200,
            color: Colors.white,
            child: StreamBuilder<RealmResultsChanges<Location>>(
              stream: realmServices.realm.all<Location>().changes,
              builder: (context, snapshot) {
                final data = snapshot.data;

                if (data == null) return waitingIndicator();

                final results = data.results;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.realm.isClosed ? 0 : results.length,
                  itemBuilder: (context, index) => results[index].isValid
                      ? LocationItem(results[index])
                      : Container(
                          color: Colors.orange,
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void createPos(RealmServices realmServices, BuildContext context,
      double latitude, double longitude) {
    final newPosition = realmServices.createLocation(latitude, longitude);
    locations = newPosition;
    _isCreated = true;
  }

  void updatePos(RealmServices realmServices, BuildContext context,
      double latitude, double longitude) {
    try {
      realmServices.updateLocation(locations, latitude, longitude);
    } catch (e) {
      debugPrint("update failed!!!!   $e");
    }
  }

  void _requestLocationPermission() async {
    final PermissionStatus status =
        await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      debugPrint("denied broo");
      // Permission denied, display a message or handle it in some other way
    }
  }

  // Callback for when the user presses and holds on the map
  _onMapLongPressed(LatLng latLng) {
    // Create a new marker at the pressed location
    setState(() {
      _markers.clear();
      _circles.clear();
      _markers.add(Marker(
        markerId: const MarkerId('selected-location'),
        position: latLng,
        icon: BitmapDescriptor.defaultMarker,
      ));

      // Draw a circle around the marker with a radius of 300 meters
      _circles.add(Circle(
        circleId: const CircleId('selected-location-circle'),
        center: latLng,
        radius: 300,
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blueAccent,
        strokeWidth: 2,
      ));
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }
}
