import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timetable_management_system/model/programme.dart';
import 'package:timetable_management_system/repository/database_repository.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class ProgrammeRepository {
  static Future<Database> openDB() async {
    WidgetsFlutterBinding.ensureInitialized();

    final database = await DatabaseRepository.openDB();

    // Check if programme table exists
    List table = await database.query("sqlite_master",
        where: "name = ?", whereArgs: [Strings.programmeTableName]);
    if (table.isEmpty) {
      database.execute(Strings.programmeTableSQL);
    }

    return database;
  }

  static Future insertProgramme(Programme prog) async {
    final db = await openDB();

    await db.insert(
      Strings.programmeTableName,
      prog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<List<Programme>> retrieveProgrammes() async {
    final db = await openDB();

    final List<Map<String, dynamic>> maps =
        await db.query(Strings.programmeTableName);

    return List.generate(
      maps.length,
      (i) => Programme(
        maps[i]['id'],
        maps[i]['programmeCode'],
      ),
    );
  }

  static Future<Programme> retrieveProgrammeById(int id) async {
    final db = await openDB();

    final List<Map<String, dynamic>> maps = await db.query(
      Strings.programmeTableName,
      where: "id = ?",
      whereArgs: [id],
    );

    return Programme(
      maps[0]['id'],
      maps[0]['programmeCode'],
    );
  }

  static Future updateProgramme(Programme prog) async {
    final db = await openDB();

    await db.update(
      Strings.programmeTableName,
      prog.toMap(),
      where: "id = ?",
      whereArgs: [prog.id],
    );
  }

  static Future deleteProgramme(int id) async {
    final db = await openDB();

    await db.delete(
      Strings.programmeTableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
