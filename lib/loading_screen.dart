
import 'package:flutter/material.dart';
import 'login_register_screen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginRegisterScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Easy Contracting",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(
                "Creating networks and opportunities for the earthworks contractor"),
          ],
        ),
      ),
    );
  }
  }