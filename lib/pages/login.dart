import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:messmeter/pages/sDate.dart';
import 'package:telephony/telephony.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../main.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final myController = TextEditingController();

  var cCode = "91";

  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void submit() {}

  Telephony telephony = Telephony.instance;

  var smsOTP = "";

  Future registerUser(String mobile, BuildContext context) async {
    telephony.listenIncomingSms(
      listenInBackground: false,
      onNewMessage: (SmsMessage message) {
        String sms = message.body.toString(); //get the message

        if (sms.contains("website-7a5a3")) {
          smsOTP = sms.substring(0, 7);
        }
      },
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(30),
                      child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.blue, size: 75))),
            ));

    FirebaseAuth _auth = FirebaseAuth.instance;

    var code;

    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential authCredential) {
          _auth
              .signInWithCredential(authCredential)
              .then((UserCredential result) async {
            var uid = result.user?.uid;
            final ref = FirebaseDatabase.instance.ref();
            final snapshot = await ref.child('Mess/$uid/sDate').get();
            if (snapshot.exists) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Counter(
                            user: result.user!,
                          )));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SDate(
                            user: result.user!,
                          )));
            }
          }).catchError((e) {
            print(e);
          });
        },
        verificationFailed: (FirebaseAuthException authException) {
          print(authException.message);
        },
        codeSent: (verificationId, forceResendingToken) => {
              if (smsOTP.isEmpty)
                {
                  // print("ok"),
                  // showDialog(
                  //     context: context,
                  //     builder: (context) => AlertDialog(
                  //           title: const Text("Enter SMS Code"),
                  //           content: Column(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: <Widget>[
                  //               TextField(
                  //                 onChanged: (value) => {code = value},
                  //                 keyboardType: TextInputType.number,
                  //               ),
                  //             ],
                  //           ),
                  //           actions: <Widget>[
                  //             TextButton(
                  //               child: const Text("Done"),
                  //               onPressed: () {
                  //                 FirebaseAuth auth = FirebaseAuth.instance;

                  //                 var smsCode = code;

                  //                 AuthCredential credential =
                  //                     PhoneAuthProvider.credential(
                  //                         verificationId: verificationId,
                  //                         smsCode: smsCode);
                  //                 auth
                  //                     .signInWithCredential(credential)
                  //                     .then((UserCredential result) async {
                  //                   var uid = result.user?.uid;
                  //                   final ref = FirebaseDatabase.instance.ref();
                  //                   final snapshot = await ref
                  //                       .child('Mess/$uid/sDate')
                  //                       .get();
                  //                   if (snapshot.exists) {
                  //                     Navigator.push(
                  //                         context,
                  //                         MaterialPageRoute(
                  //                             builder: (context) => Counter(
                  //                                   user: result.user!,
                  //                                 )));
                  //                   } else {
                  //                     Navigator.push(
                  //                         context,
                  //                         MaterialPageRoute(
                  //                             builder: (context) => SDate(
                  //                                   user: result.user!,
                  //                                 )));
                  //                   }
                  //                 }).catchError((e) {
                  //                   print(e);
                  //                 });
                  //               },
                  //             )
                  //           ],
                  //         ))
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OTPScreen(vID: verificationId)))
                }
              else
                {
                  () {
                    print('OTP is:$smsOTP');
                    FirebaseAuth auth = FirebaseAuth.instance;

                    var smsCode = code;

                    AuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: verificationId, smsCode: smsOTP);
                    auth
                        .signInWithCredential(credential)
                        .then((UserCredential result) async {
                      var uid = result.user?.uid;
                      final ref = FirebaseDatabase.instance.ref();
                      final snapshot = await ref.child('Mess/$uid/sDate').get();
                      if (snapshot.exists) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Counter(
                                      user: result.user!,
                                    )));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SDate(
                                      user: result.user!,
                                    )));
                      }
                    }).catchError((e) {
                      print(e);
                    });
                  }
                }
            },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print(verificationId);
          print("Timout");
        });
  }

  @override
  Widget build(BuildContext context) {
    return (WillPopScope(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(255, 219, 88, 1),
            automaticallyImplyLeading: false,
            title: Text(
              "MessMeter",
              style: GoogleFonts.kanit(
                  fontSize: 25, color: Color.fromRGBO(155, 114, 2, 1)),
            ),
          ),
          body: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          "Can I get your number please?",
                          style: GoogleFonts.ubuntu(
                              textStyle: TextStyle(
                                  fontSize: 40,
                                  color: Color.fromRGBO(1, 1, 1, 0.4))),
                        ))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: IntlPhoneField(
                    style: GoogleFonts.ubuntu(),
                    controller: myController,
                    disableAutoFillHints: false,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: GoogleFonts.ubuntu(),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    initialCountryCode: 'IN',
                    onCountryChanged: (country) {
                      cCode = country.dialCode;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    onPressed: () =>
                        registerUser('+$cCode${myController.text}', context),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                        backgroundColor: Color.fromRGBO(255, 219, 88, 1)),
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Send OTP',
                          style: GoogleFonts.kanit(
                              fontSize: 30,
                              color: Color.fromRGBO(155, 114, 2, 1)),
                        )),
                  ),
                )
              ],
            ),
          )),
      onWillPop: () async => false,
    ));
  }
}

class OTPScreen extends StatelessWidget {
  final String vID;
  const OTPScreen({super.key, required this.vID});

  @override
  Widget build(BuildContext context) {
    var smsCode;
    var arr = [];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 219, 88, 1),
        automaticallyImplyLeading: false,
        title: Text(
          "MessMeter",
          style: GoogleFonts.kanit(
              fontSize: 25, color: Color.fromRGBO(155, 114, 2, 1)),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  "Enter OTP",
                  style: GoogleFonts.kanit(),
                ),
              ),
            ),
            OtpTextField(
                mainAxisAlignment: MainAxisAlignment.center,
                numberOfFields: 6,
                fillColor: Colors.black.withOpacity(0.1),
                filled: true,
                autoFocus: true,
                onSubmit: (code) {
                  smsCode = code;

                  FirebaseAuth auth = FirebaseAuth.instance;

                  AuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: vID, smsCode: smsCode);
                  auth
                      .signInWithCredential(credential)
                      .then((UserCredential result) async {
                    var uid = result.user?.uid;
                    final ref = FirebaseDatabase.instance.ref();
                    final snapshot = await ref.child('Mess/$uid/sDate').get();
                    if (snapshot.exists) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Counter(
                                    user: result.user!,
                                  )));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SDate(
                                    user: result.user!,
                                  )));
                    }
                  }).catchError((e) {
                    print(e);
                  });
                }),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth auth = FirebaseAuth.instance;

                    AuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: vID, smsCode: smsCode);
                    auth
                        .signInWithCredential(credential)
                        .then((UserCredential result) async {
                      var uid = result.user?.uid;
                      final ref = FirebaseDatabase.instance.ref();
                      final snapshot = await ref.child('Mess/$uid/sDate').get();
                      if (snapshot.exists) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Counter(
                                      user: result.user!,
                                    )));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SDate(
                                      user: result.user!,
                                    )));
                      }
                    }).catchError((e) {
                      print(e);
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                          Color.fromRGBO(255, 219, 88, 1))),
                  child: Text("Continue",
                      style: GoogleFonts.kanit(
                        fontSize: 30,
                        color: Color.fromRGBO(155, 114, 2, 1),
                      ))),
            )
          ],
        ),
      ),
    );
  }
}
