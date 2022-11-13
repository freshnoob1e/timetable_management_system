import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class DatabaseRepository {
  static Future<Database> openDB() async {
    WidgetsFlutterBinding.ensureInitialized();

    final database = await openDatabase(
      join(await getDatabasesPath(), Strings.databaseName),
      onCreate: (db, version) {
        db.execute(Strings.programmeTableSQL);
        db.execute(Strings.lecturerTableSQL);
        db.execute(Strings.venueTableSQL);
      },
      version: 1,
    );

    return database;
  }
}
