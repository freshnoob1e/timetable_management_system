import 'package:sqflite/sqflite.dart';
import 'package:timetable_management_system/model/venue.dart';
import 'package:timetable_management_system/repository/database_repository.dart';
import 'package:timetable_management_system/utility/values/strings.dart';
import 'package:timetable_management_system/utility/venue_type.dart';

class VenueRepository {
  static Future<Database> openDB() async {
    final database = await DatabaseRepository.openDB();

    List table = await database.query(
      "sqlite_master",
      where: "name = ?",
      whereArgs: [Strings.venueTableName],
    );

    if (table.isEmpty) {
      database.execute(Strings.venueTableSQL);
    }

    return database;
  }

  static Future insertVenue(Venue venue) async {
    final db = await openDB();

    db.insert(
      Strings.venueTableName,
      venue.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<List<Venue>> retrieveVenues() async {
    final db = await openDB();

    List<Map<String, dynamic>> maps = await db.query(Strings.venueTableName);

    return List.generate(
      maps.length,
      (i) => Venue(
        maps[i]['id'],
        maps[i]['venueName'],
        maps[i]['venueCapacity'],
        VenueType.values[maps[i]['venueType']],
      ),
    );
  }

  static Future<Venue> retrieveVenueById(int id) async {
    final db = await openDB();

    List<Map<String, dynamic>> maps = await db.query(Strings.venueTableName);

    return Venue(
      maps[0]['id'],
      maps[0]['venueName'],
      maps[0]['venueCapacity'],
      VenueType.values[maps[0]['venueType']],
    );
  }

  static Future updateVenue(Venue venue) async {
    final db = await openDB();

    await db.update(
      Strings.venueTableName,
      venue.toMap(),
      where: "id = ?",
      whereArgs: [venue.id],
    );
  }

  static Future deleteVenue(int id) async {
    final db = await openDB();

    await db.delete(
      Strings.venueTableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
