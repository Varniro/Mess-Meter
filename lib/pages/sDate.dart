import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class SDate extends StatefulWidget {
  final User user;
  const SDate({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _SDateState();
}

class _SDateState extends State<SDate> {
  DateTime sDate = DateTime.now();
  String meal = "Lunch";
  void sub(temp) {
    sDate = temp;
  }

  @override
  void initState() {
    super.initState();
    getData();
    print("ok");
  }

  Future<void> getData() async {
    final ref = FirebaseDatabase.instance.ref();
    String uid = widget.user.uid;
    final snapshot = await ref.child('Mess/$uid/sDate').get();
    if (snapshot.exists) {
      setState(() {
        var data = snapshot.value as Map;
        sDate = DateTime(data['year'], data['month'], data['day']);
        if (data['meal'] == "Dinner") {
          meal = "Dinner";
          setDinner();
        }
      });
    }
  }

  Icon lunchIcon = Icon(
    Icons.check_box,
    color: Color.fromRGBO(155, 114, 2, 1),
  );
  Icon dinnerIcon = Icon(
    Icons.check_box_outline_blank,
    color: Color.fromARGB(255, 0, 0, 0),
  );

  Color lunchColor = Color.fromARGB(255, 253, 203, 55);
  Color dinnerColor = Color.fromARGB(255, 139, 139, 139);

  Color lunchTextColor = Color.fromRGBO(155, 114, 2, 1);
  Color DinnerTextColor = Color.fromARGB(255, 0, 0, 0);

  void setLunch() {
    meal = "Lunch";
    setState(() {
      lunchIcon = Icon(
        Icons.check_box,
        color: Color.fromRGBO(155, 114, 2, 1),
      );
      dinnerIcon = Icon(
        Icons.check_box_outline_blank,
        color: Color.fromARGB(255, 0, 0, 0),
      );
      lunchColor = Color.fromARGB(255, 253, 203, 55);
      dinnerColor = Color.fromARGB(255, 139, 139, 139);

      lunchTextColor = Color.fromRGBO(155, 114, 2, 1);
      DinnerTextColor = Color.fromARGB(255, 0, 0, 0);
    });
  }

  void setDinner() {
    meal = "Dinner";
    setState(() {
      dinnerIcon = Icon(
        Icons.check_box,
        color: Color.fromRGBO(155, 114, 2, 1),
      );
      lunchIcon = Icon(
        Icons.check_box_outline_blank,
        color: Color.fromARGB(255, 0, 0, 0),
      );
      lunchColor = Color.fromARGB(255, 139, 139, 139);
      dinnerColor = Color.fromARGB(255, 253, 203, 55);

      lunchTextColor = Color.fromARGB(255, 0, 0, 0);
      DinnerTextColor = Color.fromRGBO(155, 114, 2, 1);
    });
  }

  Future<void> set() async {
    String uid = widget.user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref('Mess/$uid');
    await ref.update({
      "sDate": {
        "year": sDate.year,
        "month": sDate.month,
        "day": sDate.day,
        "meal": meal
      }
    }).then((value) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Counter(
                  user: widget.user,
                ))));
  }

  @override
  Widget build(BuildContext context) {
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
          ),
          body: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        "Enter Month Start",
                        style: GoogleFonts.kanit(),
                      ),
                    ),
                  ),
                  Container(
                    child: CalendarDatePicker(
                        initialDate: sDate,
                        firstDate: DateTime(2021),
                        lastDate: DateTime(2026),
                        onDateChanged: (e) => {sub(e)}),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12)),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    height: MediaQuery.of(context).size.height / 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                            icon: lunchIcon,
                            style: ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                    BeveledRectangleBorder(
                                        borderRadius: BorderRadius.zero)),
                                backgroundColor:
                                    MaterialStatePropertyAll(lunchColor)),
                            onPressed: setLunch,
                            label: Text("Lunch",
                                style: GoogleFonts.kanit(
                                  fontSize:
                                      MediaQuery.of(context).size.height / 30,
                                  height: 1.2,
                                  color: lunchTextColor,
                                ))),
                        TextButton.icon(
                            icon: dinnerIcon,
                            style: ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                    BeveledRectangleBorder(
                                        borderRadius: BorderRadius.zero)),
                                backgroundColor:
                                    MaterialStatePropertyAll(dinnerColor)),
                            onPressed: setDinner,
                            label: Text("Dinner",
                                style: GoogleFonts.kanit(
                                  fontSize:
                                      MediaQuery.of(context).size.height / 30,
                                  height: 1.2,
                                  color: DinnerTextColor,
                                )))
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Color.fromRGBO(255, 219, 88, 1))),
                      child: Text("Set and Continue",
                          style: GoogleFonts.kanit(
                            color: Color.fromRGBO(155, 114, 2, 1),
                            fontSize: MediaQuery.of(context).size.height / 30,
                            height: 1.2,
                          )),
                      onPressed: set,
                    ),
                  )
                ],
              ))),
      onWillPop: () async => true,
    );
  }
}
