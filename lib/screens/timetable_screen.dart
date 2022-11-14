import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:timetable_management_system/algo/scheduler.dart';
import 'package:timetable_management_system/model/class_session.dart';
import 'package:timetable_management_system/model/course.dart';
import 'package:timetable_management_system/model/venue.dart';
import 'package:timetable_management_system/repository/course_repository.dart';
import 'package:timetable_management_system/repository/venue_repository.dart';
import 'package:timetable_management_system/screens/course_screen.dart';
import 'package:timetable_management_system/screens/lecturer_screen.dart';
import 'package:timetable_management_system/screens/manage_timeslot_screen.dart';
import 'package:timetable_management_system/screens/programme_screen.dart';
import 'package:timetable_management_system/screens/venue_screen.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  Scheduler scheduler = Scheduler();

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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageTimeslotScreen(),
                  ),
                );
              },
              child: const Text("Manage timeslot"),
            ),
            ElevatedButton(
              onPressed: () async {
                CalendarControllerProvider calendarControllerProvider =
                    CalendarControllerProvider.of(context);
                List<Course> courses = await CourseRepository.retrieveCourses();
                List<Venue> venues = await VenueRepository.retrieveVenues();

                //TODO remove hard coded value (day period/chromosome count)
                scheduler.initializeInitialTimetable(courses, 8, 5, venues);

                for (var event
                    in calendarControllerProvider.controller.events) {
                  calendarControllerProvider.controller.remove(event);
                }

                List<ClassSession> sessions =
                    scheduler.fittestTimetableClassSessions();

                for (ClassSession session in sessions) {
                  final event = CalendarEventData(
                    title:
                        "${session.course.courseCode},${session.classType.name}",
                    date: session.startTime,
                    startTime: session.startTime,
                    endTime: session.endTime,
                  );
                  calendarControllerProvider.controller.add(event);
                }
              },
              child: const Text("Generate timetable"),
            ),
            const Expanded(
              child: WeekView(),
            ),
          ],
        ),
      ),
    );
  }
}
