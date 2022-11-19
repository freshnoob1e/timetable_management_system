import 'dart:convert';

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

  Course.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        lecturer = Lecturer.fromJson(json['lecturer']),
        programmeCode = Programme.fromJson(json['programmeCode']),
        courseCode = json['courseCode'],
        courseDescription = json['courseDescription'],
        lessonsHours = lessonHourJsonToMap(json['lessonsHours']);

  static Map<ClassType, double> lessonHourJsonToMap(dynamic lessonHourJson) {
    final lessonHourDecoded = json.decode(lessonHourJson);
    Map<ClassType, double> lessonHourMap = {};
    lessonHourDecoded.forEach(
      (key, value) {
        for (var ct in ClassType.values) {
          if (ct.name == key) {
            lessonHourMap.putIfAbsent(ct, () => value);
          }
        }
      },
    );
    return lessonHourMap;
  }

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

  Map<String, dynamic> toJson() {
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
      "lecturer": lecturer.toJson(),
      "programmeCode": programmeCode.toJson(),
      "courseCode": courseCode,
      "courseDescription": courseDescription,
      "lessonsHours": lessonsHourJson,
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
    return "<Course: id: $id, CourseCode: $courseCode, ${lecturer.name}, $programmeCode, $courseDescription, Lecture: ${lessonsHours[ClassType.lecture]}, Tutorial: ${lessonsHours[ClassType.tutorial]}, Practical: ${lessonsHours[ClassType.practical]}, Blended: ${lessonsHours[ClassType.blended]}>";
  }
}
