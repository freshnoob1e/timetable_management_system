import 'package:sqflite/sqflite.dart';
import 'package:timetable_management_system/model/timeslot.dart';
import 'package:timetable_management_system/repository/database_repository.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class AppSettingRepository {
  static Future<Database> openDB() async {
    final database = await DatabaseRepository.openDB();

    // Check if deactivated timeslot table exists
    List table = await database.query("sqlite_master",
        where: "name = ?", whereArgs: [Strings.deactivatedTimeslotTableName]);

    if (table.isEmpty) {
      await database.execute(Strings.deactivatedTimeslotTableSQL);
    }

    return database;
  }

  static Future createDeactivatedTimeslots(List<TimeSlot> timeslots) async {
    final db = await openDB();

    for (var ts in timeslots) {
      await db.insert(
        Strings.deactivatedTimeslotTableName,
        ts.toMap(),
      );
    }
  }

  static Future<List<TimeSlot>> retrieveDeactivatedTimeslots() async {
    final db = await openDB();

    List<Map<String, dynamic>> maps = await db.query(
      Strings.deactivatedTimeslotTableName,
    );

    return List.generate(
      maps.length,
      (i) => TimeSlot(
        maps[i]['id'],
        DateTime.parse(maps[i]['startTime']),
        DateTime.parse(maps[i]['endTime']),
      ),
    );
  }

  static Future deleteAllDeactivatedTimeslots() async {
    final db = await openDB();

    await db.rawDelete("DELETE FROM ${Strings.deactivatedTimeslotTableName}");
  }

  static Future updateDeactivatedTimeslots(List<TimeSlot> timeslots) async {
    await deleteAllDeactivatedTimeslots();
    await createDeactivatedTimeslots(timeslots);
  }
}
