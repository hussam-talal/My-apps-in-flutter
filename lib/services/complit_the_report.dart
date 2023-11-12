import 'package:autonjm/services/viewdata.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/User.dart';
import '../screens/account/LoginPage.dart' show loggedInUsername;

class complit_the_report extends StatefulWidget {
  final double latitude;
  final double longitude;
  final DateTime currentTime;
  final String loggedInUsername;

  const complit_the_report({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.currentTime,
    required this.loggedInUsername,
  }) : super(key: key);

  @override
  State<complit_the_report> createState() => _complit_the_reportState();
}

class _complit_the_reportState extends State<complit_the_report> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  List<DocumentSnapshot>? documentList;
  List<bool> selectedUsers = [];
  Map<String, Map<String, String>> selectedCarPlateNumbers = {};
  String searchQuery = '';
  bool isItemSelected = false;

  @override
  void initState() {
    super.initState();
    fetchUserDocuments();
  }

  Future<void> fetchUserDocuments() async {
    try {
      QuerySnapshot snapshot = await users.get();
      setState(() {
        documentList = snapshot.docs;
        selectedUsers = List<bool>.filled(snapshot.docs.length, false);
      });
    } catch (e) {
      print('حدث خطأ أثناء جلب البيانات من Firestore: $e');
    }
  }

  List<DocumentSnapshot> getFilteredDocuments() {
    if (searchQuery.isEmpty) {
      return documentList ?? [];
    } else {
      return (documentList ?? []).where((doc) {
        User user = User.fromMap(doc.data() as Map<String, dynamic>);
        return user.username.contains(searchQuery) ||
            user.cars.any((car) =>
                car.plateNumber.contains(searchQuery) ||
                car.model.contains(searchQuery));
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xe61c462e),
        title: Text('    بيانات المستخدمين  '),
        centerTitle: true,
        actions: [
          Visibility(
            visible: isItemSelected,
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (selectedUsers.contains(true) &&
                    selectedCarPlateNumbers.containsKey(loggedInUsername)) {
                  if (selectedUsers.where((user) => user == true).length >= 2) {
                    List<DocumentSnapshot> selectedDocs = [];
                    for (int i = 0; i < selectedUsers.length; i++) {
                      if (selectedUsers[i]) {
                        selectedDocs.add(documentList![i]);
                      }
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectedItemsPage(
                          selectedDocuments: selectedDocs,
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                          currentTime: widget.currentTime,
                          selectedCarPlateNumbers: selectedCarPlateNumbers,
                          loggedInUsername: widget.loggedInUsername,
                        ),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('خطأ'),
                          content: Text('يرجى اختيار اسمك واسم الشخص الاخر  '),
                          actions: [
                            TextButton(
                              child: Text('أوك'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('خطأ'),
                        content: Text('يرجى اختيار اسمك'),
                        actions: [
                          TextButton(
                            child: Text('أوك'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  textDirection: TextDirection.rtl,
                  "  قم باختيار بيانات سيارتك \n  وسيارة الشخص الاخر  ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'ابحث عن رقم اللوحة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            documentList != null
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: getFilteredDocuments().length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot doc = getFilteredDocuments()[index];
                      User user =
                          User.fromMap(doc.data() as Map<String, dynamic>);

                      return Card(
                        margin: const EdgeInsets.all(10),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25.0),
                            topLeft: Radius.circular(0.0),
                            bottomLeft: Radius.circular(25.0),
                          ),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            [
                              'اسم المستخدم: ${user.username}',
                              'رقم الهاتف: ****${user.phoneNumber.substring(4)}'
                            ].join(' - '),
                            textDirection: TextDirection.rtl,
                          ),
                          children: [
                            for (int i = 0; i < user.cars.length; i++)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: selectedCarPlateNumbers
                                                .containsKey(user.username) &&
                                            selectedCarPlateNumbers[
                                                        user.username]![
                                                    'plateNumber'] ==
                                                user.cars[i].plateNumber,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedCarPlateNumbers[
                                                  user.username] = {
                                                'phoneNumber': user.phoneNumber,
                                                'plateNumber':
                                                    user.cars[i].plateNumber,
                                                'model': user.cars[i].model,
                                              };
                                            } else {
                                              selectedCarPlateNumbers
                                                  .remove(user.username);
                                            }
                                            selectedUsers[index] =
                                                value ?? false;
                                            isItemSelected =
                                                selectedUsers.contains(true);
                                          });
                                        },
                                      ),
                                      Text(
                                        ' رقم اللوحة: ${user.cars[i].plateNumber}',
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 30),
                                      Text(
                                        'موديل السيارة: ${user.cars[i].model}',
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                          onExpansionChanged: (expanded) {
                            if (!expanded) {
                              setState(() {
                                isItemSelected = selectedUsers.contains(true);
                              });
                            }
                          },
                        ),
                      );
                    },
                    physics: const NeverScrollableScrollPhysics(),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ],
        ),
      ),
    );
  }
}
