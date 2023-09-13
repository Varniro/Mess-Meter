import 'package:flutter/material.dart';
import './login.dart';
import 'package:google_fonts/google_fonts.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    void login() {
      print("hii");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }

    return (Scaffold(
        body: GestureDetector(
      onTap: login,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
        color: Color.fromRGBO(255, 219, 88, 1),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              height: 175,
            ),
            Text(
              'MessMeter',
              style: GoogleFonts.kanit(
                  fontSize: 60, color: Color.fromRGBO(155, 114, 2, 1)),
            ),
          ],
        ),
      ),
    )));
  }
}
