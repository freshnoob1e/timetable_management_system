import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:timetable_management_system/genetic_algorithm/optimize_isolate_model.dart';
import 'package:timetable_management_system/genetic_algorithm/population.dart';
import 'package:timetable_management_system/genetic_algorithm/scheduler.dart';
import 'package:timetable_management_system/model/class_session.dart';
import 'package:timetable_management_system/model/course.dart';
import 'package:timetable_management_system/model/timeslot.dart';
import 'package:timetable_management_system/model/venue.dart';
import 'package:timetable_management_system/repository/app_setting_repository.dart';
import 'package:timetable_management_system/repository/course_repository.dart';
import 'package:timetable_management_system/repository/venue_repository.dart';
import 'package:timetable_management_system/screens/course_screen.dart';
import 'package:timetable_management_system/screens/lecturer_screen.dart';
import 'package:timetable_management_system/screens/manage_timeslot_screen.dart';
import 'package:timetable_management_system/screens/programme_screen.dart';
import 'package:timetable_management_system/screens/venue_screen.dart';
import 'package:timetable_management_system/utility/class_type.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  Scheduler scheduler = Scheduler();
  bool generatedTimetable = false;

  Future generateTimetable(List<Course> courses, List<Venue> venues) async {
    scheduler = Scheduler();

    List<TimeSlot> deactivatedTimeslots =
        await AppSettingRepository.retrieveDeactivatedTimeslots();

    //TODO remove hard coded value (day period/chromosome count)
    scheduler.initializeInitialTimetable(
      courses,
      14,
      6,
      25,
      venues,
      deactivatedTimeslots,
    );
  }

  void optimizeTimetable() {
    scheduler.ga.generationCount = 0;

    compute<OptimizeIsolateModel, Population>(
      scheduler.optimize,
      OptimizeIsolateModel(toleratedConflicts: 0),
    ).then((newPopulation) {
      scheduler.ga.population = newPopulation;
      refreshTimetable();
      EasyLoading.showSuccess("Optimized timetable!");
    });
  }

  void refreshTimetable() {
    CalendarControllerProvider calendarControllerProvider =
        CalendarControllerProvider.of(context);
    for (var event in calendarControllerProvider.controller.events) {
      calendarControllerProvider.controller.remove(event);
    }

    List<ClassSession> sessions = scheduler.fittestTimetableClassSessions();

    for (ClassSession session in sessions) {
      String classTypeStr = "";
      switch (session.classType) {
        case ClassType.lecture:
          classTypeStr = "L";
          break;
        case ClassType.tutorial:
          classTypeStr = "T";
          break;
        case ClassType.practical:
          classTypeStr = "P";
          break;
        case ClassType.blended:
          classTypeStr = "B";
          break;
        default:
          classTypeStr = "Unknown";
          break;
      }
      final event = CalendarEventData(
        title: session.course.courseCode,
        event:
            "$classTypeStr, ${session.venue.venueName}&${session.course.programmeCode.programmeCode}, ${session.course.lecturer.name}",
        date: session.startTime,
        endDate: session.endTime,
        startTime: session.startTime,
        endTime: session.endTime,
      );
      calendarControllerProvider.controller.add(event);

      setState(() {});
    }
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                    EasyLoading.show(status: "Generating...");

                    List<Course> courses =
                        await CourseRepository.retrieveCourses();
                    List<Venue> venues = await VenueRepository.retrieveVenues();

                    await generateTimetable(courses, venues);

                    refreshTimetable();
                    generatedTimetable = true;

                    EasyLoading.showSuccess("Generated timetable!");
                  },
                  child: const Text("Generate timetable"),
                ),
                generatedTimetable
                    ? ElevatedButton(
                        onPressed: () {
                          EasyLoading.show(status: "Optimizing...");

                          optimizeTimetable();
                        },
                        child: const Text("Optimize table"),
                      )
                    : Container(),
                // generatedTimetable
                //     ? ElevatedButton(
                //         onPressed: () {
                //           refreshTimetable();
                //         },
                //         child: const Text("DEBUG: Refresh table"),
                //       )
                //     : Container(),
              ],
            ),
            Expanded(
              child: WeekView(
                showLiveTimeLineInAllDays: true,
                heightPerMinute: 1.5,
                eventTileBuilder:
                    (date, events, boundary, startDuration, endDuration) {
                  CalendarEventData event = events[0];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      color: Colors.deepPurple[400],
                    ),
                    child: Tooltip(
                      message:
                          "Course Code: ${event.title} | Class Type , Venue: ${event.event.toString().split("&")[0]}"
                          " | Programme, Lecturer: ${event.event.toString().split("&")[1]}",
                      child: OverflowBox(
                        maxHeight: double.infinity,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Center(
                              child: Text(
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                event.title,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                event.event.toString().split("&")[0],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                event.event.toString().split("&")[1],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
