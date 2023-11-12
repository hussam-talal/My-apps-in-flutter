import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:url_launcher/url_launcher.dart';

class Emergency extends StatefulWidget {
  const Emergency({super.key});

  @override
  State<Emergency> createState() => _EmergencyState();
}

final String emergencyNumber = '911';
final String roadPoliceNumber = '993';

class _EmergencyState extends State<Emergency> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اتصل بالاسعاف او المرور للابلاغ'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                launch('tel:$emergencyNumber');
              },
              child: const Text('اتصل بالاسعاف'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                launch('tel:$roadPoliceNumber');
              },
              child: const Text('اتصل بالمرور'),
            ),
          ],
        ),
      ),
    );
  }
}
