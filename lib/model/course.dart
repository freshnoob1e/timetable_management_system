import 'package:timetable_management_system/model/lecturer.dart';
import 'package:timetable_management_system/model/programme.dart';
import 'package:timetable_management_system/utility/class_type.dart';

class Course {
  final int? id;
  final Lecturer lecturer;
  final Programme programmeCode;
  final String courseCode;
  final String? courseDescription;
  final Map<ClassType, double> lessonsHours;

  Course(
    this.id,
    this.lecturer,
    this.programmeCode,
    this.courseCode,
    this.courseDescription,
    this.lessonsHours,
  );

  Map<String, dynamic> toMap() {
    String lessonsHourJson = "{";
    int maxCount = lessonsHours.length;
    int count = 1;
    lessonsHours.forEach(
      (key, value) {
        if (count != maxCount) {
          lessonsHourJson += "\"${key.name}\": ${value.toString()}, ";
        } else {
          lessonsHourJson += "\"${key.name}\": ${value.toString()}";
        }
        count++;
      },
    );
    lessonsHourJson += "}";
    return {
      "id": id,
      "lecturer_id": lecturer.id,
      "programme_id": programmeCode.id,
      "courseCode": courseCode,
      "courseDescription": courseDescription,
      "lessonsHour": lessonsHourJson,
    };
  }

  double totalContactHour() {
    double totalContactHour = 0;
    lessonsHours.forEach((key, value) {
      totalContactHour += value;
    });
    return totalContactHour;
  }

  @override
  String toString() {
    return "<Course: ${lecturer.name}, $programmeCode, $courseDescription, Lecture: ${lessonsHours[ClassType.lecture]}, Tutorial: ${lessonsHours[ClassType.tutorial]}, Practical: ${lessonsHours[ClassType.practical]}, Blended: ${lessonsHours[ClassType.blended]}>";
  }
}
