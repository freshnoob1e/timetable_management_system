import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timetable_management_system/model/lecturer.dart';
import 'package:timetable_management_system/repository/database_repository.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class LecturerRepository {
  static Future<Database> openDB() async {
    WidgetsFlutterBinding.ensureInitialized();

    final database = await DatabaseRepository.openDB();

    // Check if lecturer table exists
    List table = await database.query(
      "sqlite_master",
      where: "name = ?",
      whereArgs: [Strings.lecturerTableName],
    );
    if (table.isEmpty) {
      database.execute(Strings.lecturerTableSQL);
    }

    return database;
  }

  static Future insertLecturer(Lecturer lecturer) async {
    final db = await openDB();

    await db.insert(
      Strings.lecturerTableName,
      lecturer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<List<Lecturer>> retrieveLecturers() async {
    final db = await openDB();

    final List<Map<String, dynamic>> maps =
        await db.query(Strings.lecturerTableName);

    return List.generate(
      maps.length,
      (i) => Lecturer(
        maps[i]['id'],
        maps[i]['name'],
      ),
    );
  }

  static Future<Lecturer> retrieveLecturerById(int id) async {
    final db = await openDB();

    final List<Map<String, dynamic>> maps = await db
        .query(Strings.lecturerTableName, where: "id = ?", whereArgs: [id]);

    return Lecturer(maps[0]['id'], maps[0]['name']);
  }

  static Future updateLecturer(Lecturer lecturer) async {
    final db = await openDB();

    await db.update(
      Strings.lecturerTableName,
      lecturer.toMap(),
      where: "id = ?",
      whereArgs: [lecturer.id],
    );
  }

  static Future deleteLecturer(int id) async {
    final db = await openDB();

    await db.delete(
      Strings.lecturerTableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
