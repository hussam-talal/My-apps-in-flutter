import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/TrafficAccidentReport.dart';
import '../AccidentReporting.dart';
import 'SignUp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

late String loggedInUsername = '';

class _LoginPageState extends State<LoginPage> {
  late SharedPreferences _prefs;
  bool _isLoggedIn = false;

  late String nationalId;
  late String password;
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> saveLoggedInUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInUsername', username);
  }

  Future<bool> getReportSavedStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool reportSaved = prefs.getBool('report_saved') ?? false;
    return reportSaved;
  }

  Future<String?> getLoggedInUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedInUsername');
  }

  Future<void> checkLoginStatus() async {
    _prefs = await SharedPreferences.getInstance();
    _isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      bool isReportSaved = await getReportSavedStatus();
      loggedInUsername = (await getLoggedInUsername())!;

      if (isReportSaved) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrafficAccidentReport(
              loggedInUsername: loggedInUsername,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccidentReport(
              loggedInUsername: loggedInUsername,
            ),
          ),
        );
      }
    }
  }

  Future<void> saveLoginStatus() async {
    _isLoggedIn = true;
    await _prefs.setBool('isLoggedIn', _isLoggedIn);
    await _prefs.setBool('report_saved', true);
  }

  bool isPasswordVisible = false;

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0b552a),
        title: const Text('تسجيل الدخول'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                height: 260,
                child: Image.asset(
                  'asset/logo.jpg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'أهلًا بك ',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                onChanged: (value) {
                  nationalId = value;
                },
                controller: _nationalIdController,
                decoration:
                    const InputDecoration(labelText: 'السجل المدني /الإقامة'),
                style: const TextStyle(color: Color(0xff000000)),
              ),
              const SizedBox(height: 8.0),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'كلمة السر',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    child: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: isPasswordVisible ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                obscureText: !isPasswordVisible,
                style: const TextStyle(color: Color(0xff000000)),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  FirebaseFirestore firestore = FirebaseFirestore.instance;
                  firestore
                      .collection('users')
                      .where('nationalId', isEqualTo: nationalId)
                      .where('password', isEqualTo: password)
                      .get()
                      .then((QuerySnapshot snapshot) async {
                    if (snapshot.docs.isNotEmpty) {
                      loggedInUsername = snapshot.docs[0].get('username');
                      await saveLoggedInUsername(loggedInUsername);
                      saveLoginStatus();

                      bool isReportSaved = await getReportSavedStatus();

                      if (isReportSaved) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrafficAccidentReport(
                              loggedInUsername: loggedInUsername,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccidentReport(
                              loggedInUsername: loggedInUsername,
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('خطأ بكلمة السر أو السجل المدني.'),
                        ),
                      );
                    }

                    setState(() {
                      isLoading = false;
                    });
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('حدث خطأ أثناء التحقق من قاعدة البيانات.'),
                      ),
                    );

                    setState(() {
                      isLoading = false;
                    });
                  });
                },
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(228, 33, 149, 243)),
                      )
                    : const Text(
                        'تسجيل دخول',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              const SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignUpPage(
                              key: UniqueKey(),
                              loggedInUsername: loggedInUsername,
                            )),
                  );
                },
                child: const Text('تسجيل حساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
