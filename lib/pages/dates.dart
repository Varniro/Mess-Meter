import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'package:calendar_view/calendar_view.dart';

class Dates extends StatefulWidget {
  final User user;
  const Dates({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _DatesState();
}

class _DatesState extends State<Dates> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final ref = FirebaseDatabase.instance.ref();
    String uid = widget.user.uid;
    final snapshot = await ref.child('Mess/$uid').get();
    if (snapshot.exists) {
      var data = snapshot.value as Map;

      data.forEach((key, value) {
        if (key != "sDate" && key != "endDate") {
          if (value['Lunch'] != null) {
            if (value['Lunch']) {
              final event1 = CalendarEventData(
                  date: DateTime(value['year'], value['month'], value['day']),
                  event: "Off",
                  title: 'Lunch',
                  startTime:
                      DateTime(value['year'], value['month'], value['day'], 12),
                  endTime:
                      DateTime(value['year'], value['month'], value['day'], 15),
                  color: Colors.red);
              CalendarControllerProvider.of(context).controller.add(event1);
            }
          }
          if (value['Dinner'] != null) {
            if (value['Dinner']) {
              final event2 = CalendarEventData(
                  date: DateTime(value['year'], value['month'], value['day']),
                  event: "Off",
                  startTime:
                      DateTime(value['year'], value['month'], value['day'], 19),
                  endTime:
                      DateTime(value['year'], value['month'], value['day'], 21),
                  title: 'Dinner',
                  color: Colors.red);
              CalendarControllerProvider.of(context).controller.add(event2);
            }
          }
        } else if (key == 'endDate') {
          if (value['Lunch'] != null) {
            if (value['Lunch']) {
              final event1 = CalendarEventData(
                  date: DateTime(value['year'], value['month'], value['day']),
                  event: "MonthEnd",
                  title: 'Month End',
                  startTime:
                      DateTime(value['year'], value['month'], value['day'], 0),
                  endTime:
                      DateTime(value['year'], value['month'], value['day'], 1),
                  color: Colors.purple);
              CalendarControllerProvider.of(context).controller.add(event1);
            }
          }
          if (value['Dinner'] != null) {
            if (value['Dinner']) {
              final event2 = CalendarEventData(
                  date: DateTime(value['year'], value['month'], value['day']),
                  event: "MonthEnd",
                  title: 'Month End',
                  startTime:
                      DateTime(value['year'], value['month'], value['day'], 1),
                  endTime:
                      DateTime(value['year'], value['month'], value['day'], 2),
                  color: Colors.purple);
              CalendarControllerProvider.of(context).controller.add(event2);
            }
          }
        }
      });
    }
  }

  Future<void> rem(event, date) async {
    String uid = widget.user.uid;
    var dateString = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(date);
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('Mess/$uid/$dateString');
    if (event.toString().contains('Lunch')) {
      await ref.update({"Lunch": false}).then((value) =>
          CalendarControllerProvider.of(context).controller.remove(event));
    }

    if (event.toString().contains('Dinner')) {
      await ref.update({"Dinner": false}).then((value) =>
          CalendarControllerProvider.of(context).controller.remove(event));
    }
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
        child: MonthView(
          onEventTap: (event, date) => rem(event, date),
        ),
      ),
    );
  }
}
