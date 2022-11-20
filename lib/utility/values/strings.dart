class Strings {
  static const String appTitle = "Timetable Management System";
  static const String courseScreenABTitle = "Course";
  static const String lecturerABTitle = "Lecturer";
  static const String programmeABTitle = "Programme";
  static const String venueABTitle = "Venue";
  static const String courseABTitle = "Course";
  static const String manageTimeslotABTitle = "Manage Timeslot";
  static const String savedGenTimetableFileName = "generated_timetable.json";
  static const String databaseName = "timetable_management_system.db";
  static const String lecturerTableName = "lecturers";
  static const String programmeTableName = "programmes";
  static const String venueTableName = "venues";
  static const String courseTableName = "courses";
  static const String timeslotTableName = "timeslots";
  static const String deactivatedTimeslotTableName = "deactivated_timeslots";
  static const String classSessionTableName = "class_sessions";
  static const String appSettingTableName = "app_settings";
  static const String programmeTableSQL =
      "CREATE TABLE $programmeTableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, programmeCode TEXT NOT NULL)";
  static const String lecturerTableSQL =
      "CREATE TABLE $lecturerTableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT NOT NULL)";
  static const String venueTableSQL =
      "CREATE TABLE $venueTableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, venueName TEXT NOT NULL, venueCapacity INTEGER, venueType INTEGER)";
  static const String courseTableSQL =
      "CREATE TABLE $courseTableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, courseCode TEXT NOT NULL, courseDescription TEXT NOT NULL, "
      "lessonsHour JSON NOT NULL, lecturer_id INTEGER, programme_id INTEGER, "
      "CONSTRAINT fk_lecturers FOREIGN KEY (lecturer_id) REFERENCES lecturers, CONSTRAINT fk_programmes FOREIGN KEY (programme_id) REFERENCES programmes)";
  static const String courseTableSelectSQL =
      "SELECT courses.id, courses.courseCode, courses.courseDescription, courses.lessonsHour, "
      "lecturers.id AS lecturer_id, lecturers.name AS lecturer_name, "
      "programmes.id as programme_id, programmes.programmeCode AS programme_code "
      "FROM $courseTableName INNER JOIN lecturers ON lecturer_id = lecturers.id, programmes on programme_id = programmes.id";
  static const String appSettingTableSQL =
      "CREATE TABLE $appSettingTableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)";
  static const String deactivatedTimeslotTableSQL =
      "CREATE TABLE $deactivatedTimeslotTableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, startTime TEXT, endTime TEXT)";
  static const String chromosomeCountPrefKey = "ChromosomeCount";
  static const String maxGenPrefKey = "MaxGeneration";
  static const String toleratedConflictPrefKey = "ToleratedConflict";
}
