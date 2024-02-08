import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  //Format in which calendar will be displayed
  CalendarFormat _calendarFormat = CalendarFormat.month;

  //Date focused when open the calendar
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate; //date user will select

  //map to store events, key is string and contains data in form of lists
  Map<String, List> mySelectedEvents = {};

  //for storing the values in Add New Event Dialog Box
  final titleController = TextEditingController();
  final descpController = TextEditingController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedDate = _focusedDay;

    loadPreviousEvents();
  }



  loadPreviousEvents() {
    mySelectedEvents = {
      "2024-01-13": [
        {"eventDescp": "11", "eventTitle": "111"},
        {"eventDescp": "22", "eventTitle": "222"}
      ],
      "2024-01-20": [
        {"eventDescp": "20", "eventTitle": "212"},
        {"eventDescp": "200", "eventTitle": "232"}
      ],
    };
  }

  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

  _showAddEventDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                "Add New Event",
                textAlign: TextAlign.center,
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  TextField(
                    controller: descpController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => (Navigator.pop(context)),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isEmpty &&
                        descpController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Required Title and Description"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    } else {
                      print("object");
                      print(titleController.text);
                      print(descpController.text);

                      //we are checking here if the selected date is not null then there are already events added for that date
                      //here in if condition we check if for selected date when we add our event
                      //if theres any other event alredy present, if there is then we simply add other event there
                      // the data in mySelectedEvents is not null i.e., there are events present for that date already
                      setState(() {
                        if (mySelectedEvents[DateFormat('yyyy-MM-dd')
                                .format(_selectedDate!)] !=
                            null) {
                          //here we just add the event for the date(key) in the list while keeping already added events
                          //basically we have made another map within the map
                          mySelectedEvents[DateFormat('yyyy-MM-dd')
                                  .format(_selectedDate!)]
                              ?.add({
                            "eventTitle": titleController.text,
                            "eventDescp": descpController.text,
                          });
                        } else {
                          // here our key is date i.e., string in the map for which we are adding events
                          //and we have added a single event in the list for that key(date)
                          mySelectedEvents[DateFormat('yyyy-MM-dd')
                              .format(_selectedDate!)] = [
                            {
                              "eventTitle": titleController.text,
                              "eventDescp": descpController.text,
                            }
                          ];
                        }
                      });

                      print("New Event: ${json.encode(mySelectedEvents)}");
                      //so that the values are cleared from the dialog box after the event is added in the map
                      titleController.clear();
                      descpController.clear();
                      Navigator.pop(context);
                      return;
                    }
                  },
                  style:
                      TextButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: const Text(
                    "Add Event",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          "Event Calendar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          return _showAddEventDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Event"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2020),
              lastDay: DateTime(2040),
              calendarFormat: _calendarFormat,

              onDaySelected: (selectedDate, focusedDay) {
                if (!isSameDay(_selectedDate, selectedDate)) {
                  setState(() {
                    _selectedDate = selectedDate;
                    _focusedDay = focusedDay;
                  });
                }
              },
              // selectedDayPredicate: (day) {
              //   return isSameDay(_selectedDate, day);
              // },
              //
              selectedDayPredicate: (day) => (isSameDay(_selectedDate, day)),
              onPageChanged: (focusedDay) => (_focusedDay = focusedDay),
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              eventLoader: _listOfDayEvents,
            ),
            ..._listOfDayEvents(_selectedDate!).map(
              (myEvents) => ListTile(
                leading: const Icon(
                  Icons.done,
                  color: Colors.deepPurple,
                ),
                title: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text("Event Title: ${myEvents['eventTitle']}"),
                ),
                subtitle: Text("Description: ${myEvents['eventDescp']}"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
