import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timetable_management_system/model/lecturer.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class LecturerRepository {
  static Future<Database> openDB() async {
    WidgetsFlutterBinding.ensureInitialized();

    final database = openDatabase(
      join(await getDatabasesPath(), Strings.databaseName),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE ${Strings.lecturerTableName}(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT)");
      },
      version: 1,
    );
    return database;
  }

  static Future<void> insertLecturer(Lecturer lecturer) async {
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

  static Future<void> updateLecturer(Lecturer lecturer) async {
    final db = await openDB();

    await db.update(
      Strings.lecturerTableName,
      lecturer.toMap(),
      where: "id = ?",
      whereArgs: [lecturer.id],
    );
  }

  static Future<void> deleteLecturer(int id) async {
    final db = await openDB();

    await db.delete(
      Strings.lecturerTableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
