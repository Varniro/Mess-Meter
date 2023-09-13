import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:messmeter/pages/addOff.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/start.dart';
import 'pages/login.dart';
import 'pages/sDate.dart';
import 'pages/dates.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  await Permission.notification.isDenied.then(
    (bool value) {
      if (value) {
        Permission.notification.request();
      }
    },
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
          .then((value) => runApp(
                MaterialApp(
                  title: 'MessMeter',
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    fontFamily: 'Oswald',
                  ),
                  home: const Start(),
                ),
              ));
    } else {
      var uid = user.uid;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('Mess/$uid/sDate').get();
      if (snapshot.exists) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
            .then((value) => runApp(
                  MaterialApp(
                    title: 'MessMeter',
                    theme: ThemeData(
                      primarySwatch: Colors.blue,
                      fontFamily: 'Oswald',
                    ),
                    home: Counter(
                      user: user,
                    ),
                  ),
                ));
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
            .then((value) => runApp(
                  MaterialApp(
                      title: 'MessMeter',
                      theme: ThemeData(
                        primarySwatch: Colors.blue,
                        fontFamily: 'Oswald',
                      ),
                      home: SDate(user: user)),
                ));
      }
    }
  });
}

class Counter extends StatefulWidget {
  final User user;
  const Counter({super.key, required this.user});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _counter = 0;
  List<String> dList = [];
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  void signOut() {
    FirebaseAuth.instance.signOut().then((value) => Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Login())));
  }

  Future<void> _inc() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddOff(
                user: widget.user,
              )),
    );
  }

  Future<void> getdata() async {
    dList.clear();
    DateTime start = new DateTime(2023, 8, 1);
    DateTime end = new DateTime.now();
    final ref = FirebaseDatabase.instance.ref();
    String uid = widget.user.uid;
    final snapshot = await ref.child('Mess/$uid/sDate').get();
    String sMeal = "Lunch";
    if (snapshot.exists) {
      var data = snapshot.value as Map;
      start = DateTime(data['year'], data['month'], data['day']);
      sMeal = data['meal'];
    }
    List<DateTime> days = [];
    final daysToGenerate = end.difference(start).inDays;
    days = List.generate(daysToGenerate,
        (i) => DateTime(start.year, start.month, start.day + (i)));
    var count = 0;
    for (var e in days) {
      if (e.day == DateTime.now().day && e.month == DateTime.now().month) {
        if (DateTime.now().weekday == DateTime.sunday) {
          if (DateTime.now().hour > 15) {
            var term = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(e);
            dList.add('$term, Lunch');
            dList.add('$term, Lunch');
            count += 2;
          } else if (DateTime.now().hour > 21) {
            var term = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(e);
            dList.add('$term, Lunch');
            dList.add('$term, Lunch');
            dList.add('$term, Dinner');
            count += 3;
          }
        } else {
          if (DateTime.now().hour > 14) {
            var term = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(e);
            dList.add('$term, Lunch');
            count++;
          } else if (DateTime.now().hour > 21) {
            var term = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(e);
            dList.add('$term, Lunch');
            dList.add('$term, Dinner');
            count += 2;
          }
        }
      } else if (e.weekday == DateTime.sunday) {
        var term = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(e);
        dList.add('$term, Lunch');
        dList.add('$term, Lunch');
        dList.add('$term, Dinner');
        count += 3;
      } else {
        var term = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(e);
        dList.add('$term, Lunch');
        dList.add('$term, Dinner');
        count += 2;
      }
    }
    if (sMeal == "Dinner") {
      count -= 1;
    }
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('Mess/$uid/sDate');
    final snap = await starCountRef.get();
    var sDate;
    if (snap.exists) {
      var data = snap.value as Map;
      sDate = DateTime(data['year'], data['month'], data['day']);
    }
    starCountRef = FirebaseDatabase.instance.ref('Mess/$uid');
    starCountRef.onValue.listen(
      (event) async {
        for (final child in event.snapshot.children) {
          var data = child.value as Map;
          var date;

          if (child.key != 'sDate') {
            date = DateTime(data['year'], data['month'], data['day']);
            print(date);
            if (date.compareTo(DateTime.now()) == -1 &&
                date.compareTo(sDate) == 1) {
              if (date.weekday == 7) {
                if (data['Lunch'] != null) {
                  if (data['Lunch']) {
                    var term =
                        DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(date);
                    print('$term, Lunch');
                    dList.remove('$term, Lunch');
                    dList.remove('$term, Lunch');
                    count -= 2;
                  }
                }
                if (data['Dinner'] != null) {
                  if (data['Dinner']) {
                    var term =
                        DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(date);
                    dList.remove('$term, Dinner');
                    count -= 1;
                  }
                }
              } else {
                if (data['Lunch'] != null) {
                  if (data['Lunch']) {
                    var term =
                        DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(date);
                    dList.remove('$term, Lunch');
                    count -= 1;
                  }
                }
                if (data['Dinner'] != null) {
                  if (data['Dinner']) {
                    var term =
                        DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(date);
                    dList.remove('$term, Dinner');
                    count -= 1;
                  }
                }
              }
            }
          }
        }

        if (count != _counter) {
          setState(() {
            _counter = count;
          });
        }
      },
      onError: (error) {
        // Error.
      },
    );
    int cc = 0;
    for (var e in dList) {
      print('$cc:$e');
      cc++;
    }
    if (dList.length > 60) {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('Mess/$uid/endDate');
      DateFormat format = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY);
      int commaIndex = dList[59].lastIndexOf(',');
      String dString = dList[59].substring(0, commaIndex);
      DateTime end = format.parse(dString);
      String mealType = 'Lunch';
      if (dList[59].contains('Lunch')) {
        mealType = 'Lunch';
      } else {
        mealType = 'Dinner';
      }
      await ref.update({
        "day": end.day.toInt(),
        "month": end.month.toInt(),
        "year": end.year.toInt(),
        mealType: true,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for
    // the major Material Components.

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d/M/y EEEE').format(now);

    getdata();

    return WillPopScope(
      child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Color.fromRGBO(155, 114, 2, 1)),
            backgroundColor: Color.fromRGBO(255, 219, 88, 1),
            title: Text(
              'Mess Meter',
              style: GoogleFonts.kanit(
                  fontSize: 25, color: Color.fromRGBO(155, 114, 2, 1)),
            ),
            // automaticallyImplyLeading: false,
            actions: <Widget>[
              TextButton.icon(
                onPressed: signOut,
                icon: Icon(Icons.power_settings_new),
                style: ButtonStyle(
                    iconColor: MaterialStatePropertyAll(
                        Color.fromRGBO(155, 114, 2, 1))),
                label: Text(
                  'LogOut',
                  style: GoogleFonts.kanit(
                      fontSize: 15, color: Color.fromRGBO(155, 114, 2, 1)),
                ),
              )
            ],
          ),
          drawerEdgeDragWidth: MediaQuery.of(context).size.width / 2,
          drawer: Drawer(
              child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,

                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 219, 88, 1),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: MediaQuery.of(context).size.height / 10,
                          ),
                          Text(
                            "MessMeter",
                            style: GoogleFonts.kanit(
                                fontSize: 40,
                                height: 1,
                                color: Color.fromRGBO(155, 114, 2, 1)),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      tileColor: Colors.grey[200],
                      title: Row(
                        children: [
                          Icon(Icons.description_outlined),
                          Text('Check Offs!',
                              style: GoogleFonts.kanit(
                                  fontSize: 20,
                                  height: 1,
                                  color: Color.fromARGB(119, 0, 0, 0))),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CalendarControllerProvider(
                                      child: Dates(
                                        user: widget.user,
                                      ),
                                      controller: EventController(),
                                    )));
                      },
                    ),
                    ListTile(
                      tileColor: Colors.grey[200],
                      title: Row(
                        children: [
                          Icon(Icons.event),
                          Text('Change Month Start',
                              style: GoogleFonts.kanit(
                                  fontSize: 20,
                                  height: 1,
                                  color: Color.fromARGB(119, 0, 0, 0))),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SDate(
                                      user: widget.user,
                                    )));
                      },
                    ),
                    ListTile(
                      tileColor: Colors.grey[200],
                      title: Row(
                        children: [
                          Icon(Icons.restart_alt),
                          Text('Reset Complete Data',
                              style: GoogleFonts.kanit(
                                  fontSize: 20,
                                  height: 1,
                                  color: Color.fromARGB(119, 0, 0, 0))),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (builder) => Dialog(
                                    child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 40),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "You are about to reset all your data, Are you sure?",
                                        style: GoogleFonts.ubuntu(
                                            textStyle: TextStyle(
                                                fontSize: 20,
                                                color: Color.fromRGBO(
                                                    1, 1, 1, 0.7))),
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                                onPressed: () async {
                                                  String uid = widget.user.uid;
                                                  DatabaseReference ref =
                                                      FirebaseDatabase.instance
                                                          .ref('Mess/$uid');
                                                  await ref.remove().then(
                                                      (value) => Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      SDate(
                                                                        user: widget
                                                                            .user,
                                                                      ))));
                                                },
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            const Color
                                                                    .fromARGB(
                                                                255,
                                                                255,
                                                                24,
                                                                24))),
                                                child: Text(
                                                  'Yes',
                                                  style: GoogleFonts.ubuntu(
                                                      textStyle: TextStyle(
                                                          fontSize: 20,
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255))),
                                                )),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  'No',
                                                  style: GoogleFonts.ubuntu(
                                                      textStyle: TextStyle(
                                                          fontSize: 20,
                                                          color: Color.fromRGBO(
                                                              1, 1, 1, 0.7))),
                                                ))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )));
                      },
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: RichText(
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    text: TextSpan(children: [
                      TextSpan(
                          text: "Created with ",
                          style: GoogleFonts.kanit(
                              color: const Color.fromARGB(94, 0, 0, 0),
                              fontSize: 24)),
                      WidgetSpan(
                          child: Image.asset(
                        'assets/flutter.png',
                        height: 24,
                      )),
                      TextSpan(
                          text: " and ",
                          style: GoogleFonts.kanit(
                              color: const Color.fromARGB(94, 0, 0, 0),
                              fontSize: 24)),
                      WidgetSpan(
                          child: Image.asset(
                        'assets/firebase.png',
                        height: 24,
                      )),
                      TextSpan(
                        text: "\nBy ",
                        style: GoogleFonts.kanit(
                            color: const Color.fromARGB(94, 0, 0, 0),
                            fontSize: 24),
                      ),
                      TextSpan(
                          text: "Dhruv",
                          style: GoogleFonts.kanit(
                              color: Color.fromARGB(145, 233, 30, 98),
                              fontSize: 24)),
                      WidgetSpan(
                          child: Icon(
                        Icons.star_rounded,
                        color: Colors.pink,
                      )),
                    ])),
              )
            ],
          )),
          // body is the majority of the screen.
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                  child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        Text(
                          '$_counter',
                          style: GoogleFonts.kanit(fontSize: 150, height: 0.9),
                        ),
                        Text(
                          'Plates',
                          style: GoogleFonts.kanit(fontSize: 50, height: 0.9),
                        ),
                        GestureDetector(
                          onTap: () {
                            _inc();
                          },
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 11,
                                    spreadRadius: -9,
                                    offset: Offset(1, 1),
                                    color: Colors.black),
                              ],
                              color: Color.fromRGBO(255, 219, 88, 1),
                            ),
                            child: Center(
                                child: Text(
                              'Mark Off!',
                              style: GoogleFonts.kanit(
                                  fontSize: 25,
                                  color: Color.fromRGBO(155, 114, 2, 1)),
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ],
          )),
      onWillPop: () async => false,
    );
  }
}
