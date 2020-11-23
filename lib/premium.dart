import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Expanded(
              child: FlutterLogo(
            size: 100,
          )),
          Expanded(
            child: Text("You're premium user!",
                style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      )),
    );
  }
}
