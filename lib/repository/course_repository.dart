import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:timetable_management_system/model/course.dart';
import 'package:timetable_management_system/model/lecturer.dart';
import 'package:timetable_management_system/model/programme.dart';
import 'package:timetable_management_system/repository/database_repository.dart';
import 'package:timetable_management_system/repository/lecturer_repository.dart';
import 'package:timetable_management_system/utility/class_type.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class CourseRepository {
  static Future<Database> openDB() async {
    final database = await DatabaseRepository.openDB();

    // Check if table exists
    List table = await database.query("sqlite_master",
        where: "name = ?", whereArgs: [Strings.courseTableName]);

    if (table.isEmpty) {
      await database.execute(Strings.courseTableSQL);
    }

    return database;
  }

  static Future insertCourse(Course course) async {
    final db = await openDB();

    await db.insert(
      Strings.courseTableName,
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<List<Course>> retrieveCourses() async {
    final db = await openDB();

    List<Map<String, dynamic>> maps =
        await db.rawQuery(Strings.courseTableSelectSQL);

    return List.generate(maps.length, (i) => queryMapToCourse(maps[i]));
  }

  static Future<Course> retrieveCourseById(int id) async {
    final db = await openDB();

    List<Map<String, dynamic>> maps = await db
        .rawQuery("${Strings.courseTableSelectSQL} WHERE courses.id = ?", [id]);

    return queryMapToCourse(maps[0]);
  }

  static Future updateCourse(Course course) async {
    final db = await openDB();

    await db.update(
      Strings.courseTableName,
      course.toMap(),
      where: "id = ?",
      whereArgs: [course.id],
    );
  }

  static Future deleteCourse(int id) async {
    final db = await openDB();

    await db.delete(
      Strings.courseTableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  static Course queryMapToCourse(Map<String, dynamic> course) {
    Map<ClassType, double> lessonsHour = {};
    final lessonHourJson = json.decode(course['lessonsHour']);
    lessonHourJson.forEach(
      (key, value) {
        for (var ct in ClassType.values) {
          if (ct.name == key) {
            lessonsHour.putIfAbsent(ct, () => value);
          }
        }
      },
    );
    return Course(
      course['id'],
      Lecturer(
        course['lecturer_id'],
        course['lecturer_name'],
      ),
      Programme(
        course['programme_id'],
        course['programme_code'],
      ),
      course['courseCode'],
      course['courseDescription'],
      lessonsHour,
    );
  }
}
