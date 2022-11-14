import 'package:timetable_management_system/model/course.dart';
import 'package:timetable_management_system/model/venue.dart';
import 'package:timetable_management_system/utility/class_type.dart';

class ClassSession {
  final int id;
  final Course course;
  final ClassType classType;
  final Venue venue;
  final DateTime startTime;
  final DateTime endTime;

  ClassSession(
    this.id,
    this.course,
    this.classType,
    this.venue,
    this.startTime,
    this.endTime,
  );

  bool isClash(ClassSession targetSession) {
    if (targetSession.course.lecturer.id == course.lecturer.id) {
      return true;
    } else if (targetSession.course.programmeCode.id ==
        course.programmeCode.id) {
      return true;
    } else if (targetSession.venue.id == venue.id) {
      return true;
    }

    return false;
  }

  @override
  String toString() {
    return "<Class Session: $course, $classType, $venue, $startTime - $endTime>";
  }
}
