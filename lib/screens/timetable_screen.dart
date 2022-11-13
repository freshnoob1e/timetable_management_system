import 'package:flutter/material.dart';
import 'package:timetable_management_system/screens/course_screen.dart';
import 'package:timetable_management_system/screens/lecturer_screen.dart';
import 'package:timetable_management_system/screens/programme_screen.dart';
import 'package:timetable_management_system/screens/venue_screen.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appTitle),
      ),
      body: Center(
        child: Column(
          children: [
            const Text("Timetable Screen"),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CourseScreen(),
                  ),
                );
              },
              child: const Text("To course screen"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LecturerScreen(),
                  ),
                );
              },
              child: const Text("To lecturer screen"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProgrammeScreen(),
                  ),
                );
              },
              child: const Text("To programme screen"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VenueScreen(),
                  ),
                );
              },
              child: const Text("To venue screen"),
            ),
          ],
        ),
      ),
    );
  }
}
