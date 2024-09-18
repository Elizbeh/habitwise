import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendar extends StatefulWidget {
  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2035, 1, 1),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay; // Update the focused day as well
        });
      },
      headerStyle: HeaderStyle(
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(134, 41, 137, 1.0), // Primary color
        ),
        formatButtonTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        formatButtonDecoration: BoxDecoration(
          color: Color.fromRGBO(46, 197, 187, 1.0), // Secondary color
          borderRadius: BorderRadius.circular(8.0),
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Color.fromRGBO(134, 41, 137, 1.0)),
        rightChevronIcon: Icon(Icons.chevron_right, color: Color.fromRGBO(134, 41, 137, 1.0)),
      ),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Color.fromRGBO(46, 197, 187, 1.0), // Secondary color
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Color.fromRGBO(134, 41, 137, 1.0), // Primary color
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        selectedTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        weekendTextStyle: TextStyle(
          color: Colors.red,
        ),
        outsideDaysVisible: false,
        outsideDecoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Color.fromRGBO(134, 41, 137, 1.0), // Primary color
        ),
        weekendStyle: TextStyle(
          color: Color.fromRGBO(46, 197, 187, 1.0), // Secondary color
        ),
      ),
    );
  }
}
