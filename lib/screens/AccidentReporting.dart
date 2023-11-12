import 'package:autonjm/screens/account/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/Emergency.dart';
import '../screens/viewlocation.dart';

class AccidentReport extends StatefulWidget {
  final String loggedInUsername;

  const AccidentReport({
    required this.loggedInUsername,
    Key? key,
  }) : super(key: key);

  @override
  _AccidentReportState createState() => _AccidentReportState();
}

class _AccidentReportState extends State<AccidentReport> {
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('report_saved');
    await prefs.remove('loggedInUsername');

    Navigator.pushAndRemoveUntil(
      context as BuildContext,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  Future<List<QueryDocumentSnapshot>> getReports() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reports')
        .orderBy('currentTime', descending: true)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('  الابلاغ عن حادث  '),
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            logout();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'حصل معي حادث',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationDisplayPage(
                                  latitude: 0,
                                  longitude: 0,
                                  currentTime: DateTime.now(),
                                  loggedInUsername: loggedInUsername,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 50.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'يوجد أمامي حادث',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Emergency(),
                              ),
                            );
                          },
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 50.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'تقارير الحوادث',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )
              ],
            ),
            Expanded(
              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: getReports(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text('حدث خطأ في استرجاع البيانات');
                  }

                  List<QueryDocumentSnapshot> allReports = snapshot.data ?? [];
                  if (allReports.isEmpty) {
                    return const Text('لا توجد تقارير متاحة');
                  }

                  return ListView.builder(
                    itemCount: allReports.length,
                    itemBuilder: (BuildContext context, int index) {
                      QueryDocumentSnapshot report = allReports[index];
                      Map<String, dynamic> reportData =
                          report.data() as Map<String, dynamic>;
                      List<String> names = reportData['reports'].keys.toList();
                      List<String> filteredNames = names
                          .where((name) => reportData['reports'][name] != null)
                          .toList();

                      if (filteredNames.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      if (!filteredNames.contains(widget.loggedInUsername)) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        elevation: 2.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListTile(
                                title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Color(0xff0b552a),
                                ),
                                const SizedBox(width: 3.0),
                                Text(
                                  reportData['currentTime'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            )),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_pin,
                                      color: Color(0xff0b552a),
                                    ),
                                    const SizedBox(width: 3.0),
                                    Text(
                                      ' ${reportData['latitude']}, ${reportData['longitude']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                )),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(
                                reportData['reports'].length,
                                (index) {
                                  String username = reportData['reports']
                                      .keys
                                      .elementAt(index);
                                  String plateNumber = reportData['reports']
                                      [username]['plateNumber'];
                                  String phoneNumber = reportData['reports']
                                      [username]['PhoneNumber'];
                                  String model =
                                      reportData['reports'][username]['model'];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Color(0xff0b552a),
                                            ),
                                            SizedBox(width: 8.0),
                                            Text(
                                              username,
                                              textDirection: TextDirection.rtl,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.car_repair_outlined,
                                              color: Color(0xff0b552a),
                                            ),
                                            SizedBox(width: 8.0),
                                            Text(
                                              plateNumber,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              color: Color(0xff0b552a),
                                            ),
                                            SizedBox(width: 8.0),
                                            Text(
                                              phoneNumber,
                                              textDirection: TextDirection.rtl,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.directions_car_sharp,
                                              color: Color(0xff0b552a),
                                            ),
                                            SizedBox(width: 8.0),
                                            Text(
                                              model,
                                              textDirection: TextDirection.rtl,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
