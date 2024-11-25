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
          _focusedDay = focusedDay;
        });
      },
      headerStyle: HeaderStyle(
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color:  Color.fromRGBO(181, 58, 185, 1),
        ),
        formatButtonTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        formatButtonDecoration: BoxDecoration(
          color: Color.fromRGBO(46, 197, 187, 1.0), // Secondary color
          borderRadius: BorderRadius.circular(8.0),
        ),
        leftChevronIcon: Icon(Icons.chevron_left),
        rightChevronIcon: Icon(Icons.chevron_right),
      ),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Color.fromRGBO(46, 197, 187, 1.0),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color:  Color.fromRGBO(181, 58, 185, 1),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        selectedTextStyle: TextStyle(
          color: Colors.black,
        ),
        weekendTextStyle: TextStyle(
          color: Color.fromRGBO(255, 69, 58, 1.0) // Bright red
,
        ),
        outsideDaysVisible: false,
        outsideDecoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
  weekdayStyle: TextStyle(
    color: Color.fromRGBO(105, 105, 105, 1.0),
    fontWeight: FontWeight.bold,
    fontSize: 14.0, // Reduce font size if necessary
  ),
  weekendStyle: TextStyle(
    color:  Color.fromRGBO(181, 58, 185, 1),
    fontWeight: FontWeight.bold,
    fontSize: 14.0,
  ),
),

      
    );
  }
}
