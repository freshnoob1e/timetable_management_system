import 'package:timetable_management_system/model/lecturer.dart';
import 'package:timetable_management_system/model/programme.dart';
import 'package:timetable_management_system/utility/class_type.dart';

class Course {
  final int id;
  final Lecturer lecturer;
  final Programme courseCode;
  final String courseDescription;
  final Map<ClassType, double> lessonsHours;

  Course(
    this.id,
    this.lecturer,
    this.courseCode,
    this.courseDescription,
    this.lessonsHours,
  );

  double totalContactHour() {
    double totalContactHour = 0;
    lessonsHours.forEach((key, value) {
      totalContactHour += value;
    });
    return totalContactHour;
  }

  @override
  String toString() {
    return "<Course: ${lecturer.name}, $courseCode, $courseDescription, Lecture: ${lessonsHours[ClassType.lecture]}, Tutorial: ${lessonsHours[ClassType.tutorial]}, Practical: ${lessonsHours[ClassType.practical]}, Blended: ${lessonsHours[ClassType.blended]}>";
  }
}
