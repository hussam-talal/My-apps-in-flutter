import 'package:autonjm/screens/account/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/color_parser.dart';
import '../AccidentReporting.dart';
import '../../models/Car.dart';
import '../../models/User.dart';
import '../../utils/validators.dart';

class SignUpPage extends StatefulWidget {
  final String loggedInUsername;

  SignUpPage({Key? key, required this.loggedInUsername}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  Future<void> addUserToFirestore(User user) async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      QuerySnapshot duplicateUsersSnapshot = await usersCollection
          .where('username', isEqualTo: user.username)
          .get();
      if (duplicateUsersSnapshot.docs.isNotEmpty) {
        throw 'اسم المستخدم مستخدم بالفعل';
      }

      for (Car car in user.cars) {
        QuerySnapshot duplicateCarsSnapshot = await usersCollection
            .where('cars.plateNumber', isEqualTo: car.plateNumber)
            .get();
        if (duplicateCarsSnapshot.docs.isNotEmpty) {
          throw 'رقم اللوحة مستخدم بالفعل';
        }
      }

      DocumentReference newUserRef = await usersCollection.add(user.toMap());

      user = User(user.nationalId, user.phoneNumber, user.username,
          user.password, user.cars);

      print('تمت إضافة البيانات بنجاح إلى Firestore');

      DocumentSnapshot userSnapshot = await newUserRef.get();
      User newUser = User.fromMap(userSnapshot.data() as Map<String, dynamic>);
      print('بيانات المستخدم المضافة: $newUser');
    } catch (e) {
      print('حدث خطأ أثناء إضافة البيانات إلى Firestore: $e');
    }
  }

  bool isPasswordVisible = false;
  Color selectedColor = Colors.red;
  bool isCarDataComplete = false;
  bool isUsernameExists = false;
  bool isRegistrationSuccess = false;
  final List<Car> _cars = [];
  String? username;
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int _numberOfCars = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل حساب'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    showCursor: true,
                    controller: _nationalIdController,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      labelText: 'السجل المدني / الإقامة',
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xff141414)),
                    validator: (value) {
                      if (!Validators.isValidNationalId(value!)) {
                        return 'السجل المدني غير صالح';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 4.0),
                Container(
                  child: TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    showCursor: true,
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      labelText: 'رقم الجوال',
                      hintText: '0500000000',
                      hintStyle: TextStyle(
                        color: Color(0xff0b552a),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xff111111)),
                    validator: (value) {
                      if (!Validators.isValidPhoneNumber(value!)) {
                        return 'رقم الجوال غير صالح';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 4.0),
                Container(
                  child: TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    showCursor: true,
                    controller: _usernameController,
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        labelText: 'الإسم',
                        hintText: 'الاسم الرباعي'),
                    style: const TextStyle(color: Color(0xff0a0a0a)),
                    onChanged: (value) {
                      setState(() {
                        username = value;
                        loggedInUsername = value;
                      });
                    },
                    validator: (value) {
                      if (!Validators.isValidUsername(value!)) {
                        return 'اسم المستخدم غير صالح';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 4.0),
                Container(
                  child: TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    showCursor: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      labelText: 'كلمة السر',
                      helperText:
                          ' كلمة السر لا تقل عن 8 رموز \t ابدا بحرف كبير \n \t@-_&*!\t إستخدم',
                      helperStyle: const TextStyle(
                        color: Color(0xff0b552a),
                      ),
                      hintTextDirection: TextDirection.ltr,
                      suffixIcon: IconButton(
                        icon: isPasswordVisible
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    textDirection: TextDirection.ltr,
                    obscureText: !isPasswordVisible,
                    style: const TextStyle(color: Color(0xff0e0a0a)),
                    validator: (value) {
                      if (!Validators.isValidPassword(value!)) {
                        return 'كلمة السر غير صالحة';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(23.0),
                          border: Border.all(color: Colors.black),
                        ),
                        child: DropdownButton<int>(
                          value: _numberOfCars,
                          onChanged: (value) {
                            setState(() {
                              _numberOfCars = value!;
                            });
                          },
                          icon: Icon(Icons.arrow_drop_down,
                              color: Color.fromRGBO(12, 112, 3, 0.773)),
                          isDense: true,
                          items: List.generate(4, (index) {
                            return DropdownMenuItem<int>(
                              value: index + 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.local_taxi,
                                        color: Color.fromARGB(166, 32, 87, 0)),
                                    SizedBox(width: 5),
                                    Text(
                                      (index + 1).toString(),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const Text(
                        ' :عدد السيارات التي تملكها  ',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _numberOfCars,
                  itemBuilder: (context, index) {
                    if (index >= _cars.length) {
                      _cars.add(Car(
                        '',
                        '',
                        '',
                      ));
                    }
                    Car car = _cars[index];

                    return Column(
                      children: [
                        Text(
                          'السيارة رقم  ${index + 1}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'الموديل',
                            hintText: 'الشركة السنة',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _cars[index].model = value;
                              isCarDataComplete =
                                  _cars.every((car) => car.model.isNotEmpty);
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'يرجى إدخال الموديل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'لون السيارة',
                            hintText: 'لون سيارتك',
                            suffixIcon: Icon(Icons.circle,
                                color: selectedColor, size: 20),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _cars[index].color = value;

                              selectedColor =
                                  parseColor(value.replaceAll(' ', ''));
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'يرجى إدخال اللون';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          showCursor: true,
                          decoration: const InputDecoration(
                            labelText: 'رقم اللوحة',
                            helperText:
                                'على سبيل المثال\t 1234 A B C | ١٢٣٤ أ ب ج ',
                            helperStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0b552a),
                            ),
                            hintText: ' 1234 A B C | ١٢٣٤ أ ب ج ',
                            hintTextDirection: TextDirection.ltr,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _cars[index].plateNumber = value;
                            });
                          },
                          validator: (value) {
                            if (!Validators.isValidCarPlateNumber(value!)) {
                              return 'رقم اللوحة غير صالح';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: !isCarDataComplete || isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_cars.every((car) => car.model.isNotEmpty)) {
                              setState(() {
                                isLoading = true;
                              });

                              User newUser = User(
                                _nationalIdController.text,
                                _phoneNumberController.text,
                                _usernameController.text,
                                _passwordController.text,
                                _cars,
                              );

                              try {
                                await addUserToFirestore(newUser);
                                isRegistrationSuccess = true;
                              } catch (e) {
                                isUsernameExists = true;
                              }

                              setState(() {
                                isLoading = false;
                              });

                              if (isRegistrationSuccess) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccidentReport(
                                      loggedInUsername: loggedInUsername,
                                    ),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم تسجيل المستخدم بنجاح'),
                                  ),
                                );
                              } else if (isUsernameExists) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('اسم المستخدم مستخدم بالفعل'),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('يرجى إكمال بيانات السيارات'),
                                ),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(width: 8),
                            Text('جارٍ تسجيل الحساب...'),
                          ],
                        )
                      : const Text('تسجيل حساب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
