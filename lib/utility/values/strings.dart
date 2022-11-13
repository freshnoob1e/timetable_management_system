class Strings {
  static const String appTitle = "Timetable Management System";
  static const String courseScreenABTitle = "Course";
  static const String lecturerABTitle = "Lecturer";
  static const String programmeABTitle = "Programme";
  static const String venueABTitle = "Venue";
  static const String databaseName = "timetable_management_system.db";
  static const String lecturerTableName = "lecturers";
  static const String programmeTableName = "programmes";
  static const String venueTableName = "venues";
  static const String courseTableName = "courses";
  static const String timeslotTableName = "timeslots";
  static const String classSessionTableName = "class_sessions";
  static const String programmeTableSQL =
      "CREATE TABLE $programmeTableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, programmeCode TEXT NOT NULL)";
  static const String lecturerTableSQL =
      "CREATE TABLE $lecturerTableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT NOT NULL)";
  static const String venueTableSQL =
      "CREATE TABLE $venueTableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, venueName TEXT NOT NULL, venueCapacity INTEGER, venueType INTEGER)";
}
