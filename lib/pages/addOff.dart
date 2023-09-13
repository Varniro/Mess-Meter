import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class AddOff extends StatefulWidget {
  final User user;
  const AddOff({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _addOffState();
}

class _addOffState extends State<AddOff> {
  var meal = "Lunch";
  var meal2 = "Dinner";

  var mealIcon = Icon(Icons.sunny);
  var mealIcon2 = Icon(Icons.dark_mode);

  var from = DateTime.now();
  var to = DateTime.now().add(Duration(days: 1));

  var fromIconTheme =
      const MaterialStatePropertyAll(Color.fromARGB(255, 253, 203, 55));

  var toIconTheme =
      const MaterialStatePropertyAll(Color.fromARGB(255, 16, 0, 62));

  void change() {
    if (meal == "Lunch") {
      setState(() {
        meal = "Dinner";
        fromIconTheme =
            const MaterialStatePropertyAll(Color.fromARGB(255, 16, 0, 62));
        mealIcon = Icon(Icons.dark_mode);
      });
    } else if (meal == "Dinner") {
      setState(() {
        meal = "Lunch";
        fromIconTheme =
            const MaterialStatePropertyAll(Color.fromARGB(255, 253, 203, 55));
        mealIcon = Icon(Icons.sunny);
      });
    }
  }

  void change2() {
    if (meal2 == "Lunch") {
      setState(() {
        meal2 = "Dinner";
        mealIcon2 = Icon(Icons.dark_mode);
        toIconTheme =
            const MaterialStatePropertyAll(Color.fromARGB(255, 16, 0, 62));
      });
    } else if (meal2 == "Dinner") {
      setState(() {
        meal2 = "Lunch";
        toIconTheme =
            const MaterialStatePropertyAll(Color.fromARGB(255, 253, 203, 55));
        mealIcon2 = Icon(Icons.sunny);
      });
    }
  }

  void setFrom(time) {
    setState(() {
      from = time;
    });
  }

  void setTo(time) {
    setState(() {
      to = time;
    });
  }

  void showFrom() {
    showDialog(
        context: context,
        builder: (builder) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CalendarDatePicker(
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2026),
                    initialDate: from,
                    onDateChanged: (e) => {setFrom(e)},
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Done'),
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.grey),
                        foregroundColor:
                            MaterialStatePropertyAll(Colors.white)),
                  )
                ],
              ),
            ));
  }

  void showTo() {
    showDialog(
        context: context,
        builder: (builder) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CalendarDatePicker(
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2026),
                    initialDate: to,
                    onDateChanged: (e) => {setTo(e)},
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Done'),
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.grey),
                        foregroundColor:
                            MaterialStatePropertyAll(Colors.white)),
                  )
                ],
              ),
            ));
  }

  Future<void> sub() async {
    var uid = widget.user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref('Mess/$uid');
    var days = to.difference(from).inDays;
    var fromString = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(from);
    if (days == 0) {
      if (meal == meal2) {
        ref = FirebaseDatabase.instance.ref('Mess/$uid/$fromString');
        await ref.update({
          "day": from.day.toInt(),
          "month": from.month.toInt(),
          "year": from.year.toInt(),
          meal: true,
        });
      } else {
        ref = FirebaseDatabase.instance.ref('Mess/$uid/$fromString');
        await ref.update({
          "day": from.day.toInt(),
          "month": from.month.toInt(),
          "year": from.year.toInt(),
          "Lunch": true,
          "Dinner": true,
        });
      }
    } else {
      for (int i = 0; i <= days; i++) {
        if (i == 0) {
          if (meal == "Dinner") {
            ref = FirebaseDatabase.instance.ref('Mess/$uid/$fromString');
            await ref.update({
              "day": from.day.toInt(),
              "month": from.month.toInt(),
              "year": from.year.toInt(),
              "Dinner": true
            });
          } else {
            ref = FirebaseDatabase.instance.ref('Mess/$uid/$fromString');
            await ref.update({
              "day": from.day.toInt(),
              "month": from.month.toInt(),
              "year": from.year.toInt(),
              "Dinner": true,
              "Lunch": true,
            });
          }
        } else {
          if (i == days) {
            if (meal2 == "Dinner") {
              DateTime temp = from.add(Duration(days: i));
              String tempString =
                  DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(temp);
              ref = FirebaseDatabase.instance.ref('Mess/$uid/$tempString');
              await ref.update({
                "day": temp.day.toInt(),
                "month": temp.month.toInt(),
                "year": temp.year.toInt(),
                "Dinner": true,
                "Lunch": true,
              });
            } else {
              DateTime temp = from.add(Duration(days: i));
              String tempString =
                  DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(temp);
              ref = FirebaseDatabase.instance.ref('Mess/$uid/$tempString');
              await ref.update({
                "day": temp.day.toInt(),
                "month": temp.month.toInt(),
                "year": temp.year.toInt(),
                "Lunch": true,
              });
            }
          } else {
            DateTime temp = from.add(Duration(days: i));
            String tempString =
                DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(temp);
            ref = FirebaseDatabase.instance.ref('Mess/$uid/$tempString');
            await ref.update({
              "day": temp.day.toInt(),
              "month": temp.month.toInt(),
              "year": temp.year.toInt(),
              "Dinner": true,
              "Lunch": true,
            });
          }
        }
      }
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Counter(
                  user: widget.user,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            margin: EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      "Choose the Dates",
                      style: GoogleFonts.kanit(),
                    ),
                  ),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black12)),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: GestureDetector(
                                  onTap: () {
                                    showFrom();
                                  },
                                  child: Container(
                                      child: Text(DateFormat(DateFormat
                                              .YEAR_ABBR_MONTH_WEEKDAY_DAY)
                                          .format(from)))),
                            ),
                          )),
                      Expanded(
                          child: Container(
                              width: double.infinity,
                              child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: TextButton.icon(
                                    style: ButtonStyle(
                                      iconColor: fromIconTheme,
                                    ),
                                    icon: mealIcon,
                                    onPressed: change,
                                    label: Text(meal),
                                  ))))
                    ],
                  ),
                ),
                Text(
                  "To",
                  style: GoogleFonts.kanit(fontSize: 30),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black12)),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: GestureDetector(
                                  onTap: () {
                                    showTo();
                                  },
                                  child: Container(
                                      child: Text(DateFormat(DateFormat
                                              .YEAR_ABBR_MONTH_WEEKDAY_DAY)
                                          .format(to)))),
                            ),
                          )),
                      Expanded(
                          child: Container(
                              width: double.infinity,
                              child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: TextButton.icon(
                                    icon: mealIcon2,
                                    style: ButtonStyle(iconColor: toIconTheme),
                                    onPressed: change2,
                                    label: Text(meal2),
                                  ))))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: ElevatedButton(
                      onPressed: sub,
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Color.fromRGBO(255, 219, 88, 1))),
                      child: Text("Add Off",
                          style: GoogleFonts.kanit(
                            fontSize: 30,
                            color: Color.fromRGBO(155, 114, 2, 1),
                          ))),
                )
              ],
            )));
  }
}
