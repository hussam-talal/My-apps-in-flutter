import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/AccidentReporting.dart';

class SelectedItemsPage extends StatelessWidget {
  final List<DocumentSnapshot> selectedDocuments;
  final Map<String, Map<String, String>> selectedCarPlateNumbers;
  final double latitude;
  final double longitude;
  final DateTime currentTime;
  final String loggedInUsername;

  SelectedItemsPage({
    super.key,
    required this.selectedDocuments,
    required this.selectedCarPlateNumbers,
    required this.latitude,
    required this.longitude,
    required this.currentTime,
    required this.loggedInUsername,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> _saveReport(BuildContext context) async {
      CollectionReference reportsCollection =
          FirebaseFirestore.instance.collection('reports');

      Map<String, dynamic> reportData = {
        'latitude': latitude,
        'longitude': longitude,
        'currentTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime),
        'reports': {},
      };

      for (int i = 0; i < selectedCarPlateNumbers.length; i++) {
        String username = selectedCarPlateNumbers.keys.elementAt(i);
        Map<String, String> carData =
            selectedCarPlateNumbers.values.elementAt(i);
        String phoneNumber = carData['phoneNumber'] ?? '';
        String plateNumber = carData['plateNumber'] ?? '';
        String model = carData['model'] ?? '';

        reportData['reports'][username] = {
          'plateNumber': plateNumber,
          'PhoneNumber': phoneNumber,
          'model': model,
        };
      }
      await reportsCollection.add(reportData);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool('report_saved', true);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccidentReport(
            loggedInUsername: loggedInUsername,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(' تكوين التقرير'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: selectedCarPlateNumbers.length,
              itemBuilder: (BuildContext context, int index) {
                String username = selectedCarPlateNumbers.keys.elementAt(index);
                Map<String, String> carData =
                    selectedCarPlateNumbers.values.elementAt(index);
                String phoneNumber = carData['phoneNumber'] ?? '';
                String plateNumber = carData['plateNumber'] ?? '';
                String model = carData['model'] ?? '';
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  child: ListTile(
                    title: Text(
                      username,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '$model',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xff0b552a),
                                    ),
                                  ),
                                  const SizedBox(width: 5.0),
                                  const AnimatedDefaultTextStyle(
                                    duration: Duration(milliseconds: 500),
                                    style: TextStyle(
                                      color: Colors.teal,
                                    ),
                                    child: Text(
                                      'موديل السيارة',
                                      style: TextStyle(
                                        color: Color(0xff0b552a),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'الموقع',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_pin,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 3.0),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 500),
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xff0b552a),
                                    ),
                                    child: Text(
                                      '${latitude}, ${longitude}',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 3.0),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 500),
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xff0b552a),
                                    ),
                                    child: Text(
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(currentTime),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'رقم الهاتف: ****${phoneNumber.substring(4)}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xff0b552a),
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '$plateNumber',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xff0b552a),
                                    ),
                                  ),
                                  const SizedBox(width: 5.0),
                                  const AnimatedDefaultTextStyle(
                                    duration: Duration(milliseconds: 500),
                                    style: TextStyle(
                                      color: Color(0xff0b552a),
                                    ),
                                    child: Text(
                                      'رقم اللوحة',
                                      style: TextStyle(
                                        color: Color(0xff0b552a),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () => _saveReport(context),
              child: const Text('حفظ التقرير'),
            ),
          ],
        ),
      ),
    );
  }
}
