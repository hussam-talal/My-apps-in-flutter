import 'package:autonjm/services/complit_the_report.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class LocationDisplayPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final DateTime currentTime;
  final String loggedInUsername;

  LocationDisplayPage({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.currentTime,
    required this.loggedInUsername,
  }) : super(key: key);

  Future<void> _getLocation(BuildContext context) async {
    final location = Location();
    String formatDateTime(DateTime dateTime) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(dateTime);
    }

    bool serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    _onPosition(
      context,
      Position(
        latitude: _locationData.latitude!,
        longitude: _locationData.longitude!,
        timestamp: currentTime,
        speed: 0,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ),
    );
  }

  void _onPosition(BuildContext context, Position position) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationDisplayPage(
          latitude: position.latitude,
          longitude: position.longitude,
          currentTime: DateTime.now(),
          loggedInUsername: loggedInUsername,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0b552a),
        title: Text('حدد الموقع '),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(color: Colors.black),
              ),
              child: const Text(
                'قف وسط السيارتين',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0b552a),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              'خطوط الطول و دوائر العرض',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF36B66B),
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.location_pin),
                const SizedBox(
                  width: 3.0,
                ),
                SelectableText.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 15.0),
                    children: [
                      TextSpan(
                        text: ' $latitude',
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0b552a),
                        ),
                      ),
                      TextSpan(
                        text: ',$longitude',
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0b552a),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _getLocation(context),
              child: const Text(
                'الحصول على الموقع الحالي',
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => complit_the_report(
                      latitude: latitude,
                      longitude: longitude,
                      currentTime: DateTime.now(),
                      loggedInUsername: loggedInUsername,
                    ),
                  ),
                );
              },
              child: const Text(
                ' الخطوات التاليه',
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
