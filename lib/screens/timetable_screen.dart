import 'dart:convert';
import 'dart:io';

import 'package:calendar_view/calendar_view.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:timetable_management_system/genetic_algorithm/optimize_isolate_model.dart';
import 'package:timetable_management_system/genetic_algorithm/population.dart';
import 'package:timetable_management_system/genetic_algorithm/scheduler.dart';
import 'package:timetable_management_system/model/class_session.dart';
import 'package:timetable_management_system/model/course.dart';
import 'package:timetable_management_system/model/timeslot.dart';
import 'package:timetable_management_system/model/venue.dart';
import 'package:timetable_management_system/repository/app_setting_repository.dart';
import 'package:timetable_management_system/repository/course_repository.dart';
import 'package:timetable_management_system/repository/venue_repository.dart';
import 'package:timetable_management_system/screens/course_screen.dart';
import 'package:timetable_management_system/screens/lecturer_screen.dart';
import 'package:timetable_management_system/screens/manage_timeslot_screen.dart';
import 'package:timetable_management_system/screens/programme_screen.dart';
import 'package:timetable_management_system/screens/venue_screen.dart';
import 'package:timetable_management_system/utility/class_type.dart';
import 'package:timetable_management_system/utility/color_hex.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  Scheduler scheduler = Scheduler();
  bool generatedTimetable = false;
  List<ClassSession> sessions = [];
  int currentFilterType = 0;
  String currentVenueVal = "";
  String currentCourseVal = "";
  String currentProgVal = "";
  String currentLectVal = "";

  Future generateTimetable(List<Course> courses, List<Venue> venues) async {
    scheduler = Scheduler();

    List<TimeSlot> deactivatedTimeslots =
        await AppSettingRepository.retrieveDeactivatedTimeslots();

    //TODO remove hard coded value (day period/chromosome count)
    scheduler.initializeInitialTimetable(
      courses,
      14,
      8,
      25,
      venues,
      deactivatedTimeslots,
    );
  }

  void optimizeTimetable() {
    scheduler.ga.generationCount = 0;

    compute<OptimizeIsolateModel, Population>(
      scheduler.optimize,
      OptimizeIsolateModel(toleratedConflicts: 0),
    ).then((newPopulation) {
      scheduler.ga.population = newPopulation;
      refreshTimetable();
      EasyLoading.showSuccess("Optimized timetable!");
    });
  }

  void refreshTimetable() {
    CalendarControllerProvider calendarControllerProvider =
        CalendarControllerProvider.of(context);
    for (var event in calendarControllerProvider.controller.events) {
      calendarControllerProvider.controller.remove(event);
    }
    sessions = [];
    sessions = scheduler.fittestTimetableClassSessions();

    for (ClassSession session in sessions) {
      String classTypeStr = "";
      switch (session.classType) {
        case ClassType.lecture:
          classTypeStr = "L";
          break;
        case ClassType.tutorial:
          classTypeStr = "T";
          break;
        case ClassType.practical:
          classTypeStr = "P";
          break;
        case ClassType.blended:
          classTypeStr = "B";
          break;
        default:
          classTypeStr = "Unknown";
          break;
      }
      String eventStr =
          "$classTypeStr, ${session.venue.venueName}&${session.course.programmeCode.programmeCode}, ${session.course.lecturer.name}";
      bool hasClash = false;
      if (session.isAnyHardClash(sessions)) {
        hasClash = true;
      }
      if (hasClash) {
        eventStr += "&true";
      } else {
        eventStr += "&false";
      }

      final event = CalendarEventData(
        title: session.course.courseCode,
        event: eventStr,
        date: session.startTime,
        endDate: session.endTime,
        startTime: session.startTime,
        endTime: session.endTime,
      );
      calendarControllerProvider.controller.add(event);
    }
    setState(() {});
  }

  void refreshTimetableWithFilter() {
    if (currentFilterType == 0) {
      refreshTimetable();
      return;
    }
    CalendarControllerProvider calendarControllerProvider =
        CalendarControllerProvider.of(context);
    for (var event in calendarControllerProvider.controller.events) {
      calendarControllerProvider.controller.remove(event);
    }

    List<ClassSession> filteredSession = [];

    for (ClassSession session in sessions) {
      if (currentFilterType == 1) {
        if (session.venue.venueName == currentVenueVal) {
          filteredSession.add(session);
        }
      } else if (currentFilterType == 2) {
        if (session.course.courseCode == currentCourseVal) {
          filteredSession.add(session);
        }
      } else if (currentFilterType == 3) {
        if (session.course.programmeCode.programmeCode == currentProgVal) {
          filteredSession.add(session);
        }
      } else {
        if (session.course.lecturer.name == currentLectVal) {
          filteredSession.add(session);
        }
      }
    }

    for (ClassSession session in filteredSession) {
      String classTypeStr = "";
      switch (session.classType) {
        case ClassType.lecture:
          classTypeStr = "L";
          break;
        case ClassType.tutorial:
          classTypeStr = "T";
          break;
        case ClassType.practical:
          classTypeStr = "P";
          break;
        case ClassType.blended:
          classTypeStr = "B";
          break;
        default:
          classTypeStr = "Unknown";
          break;
      }
      String eventStr =
          "$classTypeStr, ${session.venue.venueName}&${session.course.programmeCode.programmeCode}, ${session.course.lecturer.name}";
      bool hasClash = false;
      if (session.isAnyHardClash(filteredSession)) {
        hasClash = true;
      }
      if (hasClash) {
        eventStr += "&true";
      } else {
        eventStr += "&false";
      }

      final event = CalendarEventData(
        title: session.course.courseCode,
        event: eventStr,
        date: session.startTime,
        endDate: session.endTime,
        startTime: session.startTime,
        endTime: session.endTime,
      );
      calendarControllerProvider.controller.add(event);
    }
    setState(() {});
  }

  Future<File> localFile() async {
    Directory appDocDir = await getApplicationSupportDirectory();
    String appDocPath = appDocDir.path;
    return File("$appDocPath/${Strings.savedGenTimetableFileName}");
  }

  Future saveGeneratedTimetable() async {
    try {
      Map<String, Map<String, dynamic>> jsonMap = {};

      sessions = [];
      sessions = scheduler.fittestTimetableClassSessions();

      int i = 0;
      for (var session in sessions) {
        jsonMap.putIfAbsent(i.toString(), () => session.toJson());
        i++;
      }
      String jsonString = json.encode(jsonMap);

      File saveFile = await localFile();

      saveFile.writeAsString(jsonString);
      EasyLoading.showSuccess("Saved successful!");
    } catch (e) {
      EasyLoading.showError("Something went wrong...");
    }
  }

  Future loadGeneratedTimetable() async {
    try {
      CalendarControllerProvider calendarControllerProvider =
          CalendarControllerProvider.of(context);
      for (var event in calendarControllerProvider.controller.events) {
        calendarControllerProvider.controller.remove(event);
      }

      final file = await localFile();

      final String jsonContent = await file.readAsString();
      Map<String, dynamic> map = json.decode(jsonContent);

      sessions = [];
      map.forEach((key, value) {
        sessions.add(ClassSession.fromJson(value));
      });

      for (ClassSession session in sessions) {
        String classTypeStr = "";
        switch (session.classType) {
          case ClassType.lecture:
            classTypeStr = "L";
            break;
          case ClassType.tutorial:
            classTypeStr = "T";
            break;
          case ClassType.practical:
            classTypeStr = "P";
            break;
          case ClassType.blended:
            classTypeStr = "B";
            break;
          default:
            classTypeStr = "Unknown";
            break;
        }
        String eventStr =
            "$classTypeStr, ${session.venue.venueName}&${session.course.programmeCode.programmeCode}, ${session.course.lecturer.name}";
        bool hasClash = false;
        if (session.isAnyHardClash(sessions)) {
          hasClash = true;
        }
        if (hasClash) {
          eventStr += "&true";
        } else {
          eventStr += "&false";
        }

        final event = CalendarEventData(
          title: session.course.courseCode,
          event: eventStr,
          date: session.startTime,
          endDate: session.endTime,
          startTime: session.startTime,
          endTime: session.endTime,
        );
        calendarControllerProvider.controller.add(event);
      }
      setState(() {});
      EasyLoading.showSuccess("Load successful!");
    } catch (e) {
      print(e.toString());
      EasyLoading.showError("Something went wrong...");
      return 0;
    }
  }

  DropdownButton? filterTypeDD() {
    switch (currentFilterType) {
      case 1:
        return venueDDMenuItemWidgets();
      case 2:
        return courseDDMenuItemWidgets();
      case 3:
        return progDDMenuItemWidgets();
      case 4:
        return lecturerDDMenuItemWidgets();
      default:
        return null;
    }
  }

  DropdownButton venueDDMenuItemWidgets() {
    List<String> venuesName = [];
    for (ClassSession session in sessions) {
      venuesName.add(session.venue.venueName);
    }
    venuesName = venuesName.toSet().toList();
    if (currentVenueVal == "") {
      currentVenueVal = venuesName[0];
    }
    return DropdownButton(
      value: currentVenueVal,
      items: List.generate(
        venuesName.length,
        (index) => DropdownMenuItem(
          value: venuesName[index],
          child: Text(venuesName[index]),
        ),
      ),
      onChanged: (value) {
        setState(() {
          currentVenueVal = value;
          refreshTimetableWithFilter();
        });
      },
    );
  }

  DropdownButton courseDDMenuItemWidgets() {
    List<String> coursesCodes = [];
    for (ClassSession session in sessions) {
      coursesCodes.add(session.course.courseCode);
    }
    coursesCodes = coursesCodes.toSet().toList();
    if (currentCourseVal == "") {
      currentCourseVal = coursesCodes[0];
    }
    return DropdownButton(
      value: currentCourseVal,
      items: List.generate(
        coursesCodes.length,
        (index) => DropdownMenuItem(
          value: coursesCodes[index],
          child: Text(coursesCodes[index]),
        ),
      ),
      onChanged: (value) {
        setState(() {
          currentCourseVal = value;
          refreshTimetableWithFilter();
        });
      },
    );
  }

  DropdownButton progDDMenuItemWidgets() {
    List<String> progsCodes = [];
    for (ClassSession session in sessions) {
      progsCodes.add(session.course.programmeCode.programmeCode);
    }
    progsCodes = progsCodes.toSet().toList();
    if (currentProgVal == "") {
      currentProgVal = progsCodes[0];
    }
    return DropdownButton(
      value: currentProgVal,
      items: List.generate(
        progsCodes.length,
        (index) => DropdownMenuItem(
          value: progsCodes[index],
          child: Text(progsCodes[index]),
        ),
      ),
      onChanged: (value) {
        setState(() {
          currentProgVal = value;
          refreshTimetableWithFilter();
        });
      },
    );
  }

  DropdownButton lecturerDDMenuItemWidgets() {
    List<String> lecturersNames = [];
    for (ClassSession session in sessions) {
      lecturersNames.add(session.course.lecturer.name);
    }
    lecturersNames = lecturersNames.toSet().toList();
    if (currentLectVal == "") {
      currentLectVal = lecturersNames[0];
    }
    return DropdownButton(
      value: currentLectVal,
      items: List.generate(
        lecturersNames.length,
        (index) => DropdownMenuItem(
          value: lecturersNames[index],
          child: Text(lecturersNames[index]),
        ),
      ),
      onChanged: (value) {
        setState(() {
          currentLectVal = value;
          refreshTimetableWithFilter();
        });
      },
    );
  }

  void resetFilter() {
    setState(() {
      currentFilterType = 0;
      currentVenueVal = "";
      currentCourseVal = "";
      currentProgVal = "";
      currentLectVal = "";
    });
  }

  void createExcelFile() {
    if (sessions.isEmpty) {
      EasyLoading.showError("There are not session to export");
      return;
    }
    var xlsx = Excel.createExcel();

    // Master Timetable
    Sheet defaultSheet = xlsx.sheets[xlsx.getDefaultSheet()]!;

    // Header
    CellStyle headerCellStyle =
        CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);
    defaultSheet.merge(
      CellIndex.indexByString("A3"),
      CellIndex.indexByString("Z3"),
    );
    defaultSheet.cell(CellIndex.indexByString("A3")).value =
        "TUNKU ABDUL RAHMAN UNIVERSITY OF MANAGEMENT AND TECHNOLOGY";
    defaultSheet.cell(CellIndex.indexByString("A3")).cellStyle =
        headerCellStyle;
    defaultSheet.merge(
      CellIndex.indexByString("A4"),
      CellIndex.indexByString("Z4"),
    );
    defaultSheet.cell(CellIndex.indexByString("A4")).value = "PAHANG BRANCH";
    defaultSheet.cell(CellIndex.indexByString("A4")).cellStyle =
        headerCellStyle;
    defaultSheet.merge(
      CellIndex.indexByString("A5"),
      CellIndex.indexByString("Z5"),
    );
    defaultSheet.cell(CellIndex.indexByString("A5")).value = "MASTER TIMETABLE";
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle =
        headerCellStyle;

    // Get list of programme for rendering organized timetable
    List<String> progNames = [];
    Map<String, ClassSession> sessionsMap = {};
    for (ClassSession session in sessions) {
      progNames.add(session.course.programmeCode.programmeCode);
    }
    // Make unique programme name list
    progNames = progNames.toSet().toList();
    Map<int, Map<String, List<ClassSession>>> loopMap = {};
    for (ClassSession session in sessions) {
      // If key exists, update map
      loopMap.update(
        session.startTime.weekday,
        (Map<String, List<ClassSession>> value) {
          // If key exists
          // Get list from programme and add new session
          // Else
          // Initiate new session list
          // Then update map
          List<ClassSession> classSessions = [];
          Map<String, List<ClassSession>> newMap = value;
          if (value.containsKey(session.course.programmeCode.programmeCode)) {
            classSessions = value[session.course.programmeCode.programmeCode]!;
            classSessions.add(session);
          } else {
            classSessions = [session];
          }
          newMap.addAll(
              {session.course.programmeCode.programmeCode: classSessions});

          return newMap;
        },
        ifAbsent: () => {
          session.course.programmeCode.programmeCode: [session]
        },
      );
    }
    loopMap = Map.fromEntries(
      loopMap.entries.toList()
        ..sort(
          (a, b) => a.key.compareTo(b.key),
        ),
    );

    // Map timeslot to col index
    Map<String, int> timeslotMap = {};
    DateTime d = DateTime.now();
    // only need the hour & min
    d = DateTime(d.year, d.month, d.day, 8, 0);
    for (int x = 2; x <= 25; x++) {
      DateTime currentStartTime = d.add(
        Duration(
          minutes: 30 * (x - 2),
        ),
      );
      timeslotMap.addAll(
        {
          DateFormat('H:m').format(currentStartTime): x,
        },
      );
    }

    // Create master timetable
    int currentRow = 8;

    loopMap.forEach((int k, Map<String, List<ClassSession>> v) {
      timetableRowHeader(defaultSheet, currentRow);
      currentRow++;
      // Monday - Sunday
      // Set Week Days
      defaultSheet.merge(
        CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: currentRow,
        ),
        CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: currentRow + (progNames.length * 5) - 1,
        ),
      );
      String weekDayStr = "";
      if (k == 1) {
        weekDayStr = "Monday";
      } else if (k == 2) {
        weekDayStr = "Tuesday";
      } else if (k == 3) {
        weekDayStr = "Wednesday";
      } else if (k == 4) {
        weekDayStr = "Thursday";
      } else if (k == 5) {
        weekDayStr = "Friday";
      } else if (k == 6) {
        weekDayStr = "Saturday";
      } else if (k == 7) {
        weekDayStr = "Sunday";
      }
      defaultSheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: currentRow,
            ),
          )
          .value = weekDayStr;
      defaultSheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: currentRow,
            ),
          )
          .cellStyle = CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
      );

      // Set Programmes
      for (int x = 0; x < progNames.length; x++) {
        String name = progNames[x];
        int currentClassRowIndex = (x * 5) + currentRow;

        defaultSheet.merge(
          CellIndex.indexByColumnRow(
            columnIndex: 1,
            rowIndex: currentClassRowIndex,
          ),
          CellIndex.indexByColumnRow(
            columnIndex: 1,
            rowIndex: currentClassRowIndex + 4,
          ),
        );
        var cell = defaultSheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: 1,
            rowIndex: currentClassRowIndex,
          ),
        );
        cell.value = name;
        cell.cellStyle = CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
        );
      }

      // Set classes
      int colorIndex = 0;

      Map<String, String> colorMapping = {};
      for (ClassSession session in sessions) {
        colorMapping.putIfAbsent(
          session.course.courseCode,
          () => ColorHex.colorHexs[(colorIndex++) % ColorHex.colorHexs.length],
        );
      }

      v.forEach((String key, List<ClassSession> value) {
        // Each prog
        int currentClassRowIndex = 0;
        for (String name in progNames) {
          if (name == key) {
            break;
          }
          currentClassRowIndex++;
        }

        currentClassRowIndex = (5 * currentClassRowIndex) + currentRow;

        for (ClassSession session in value) {
          int currentClassStartColIndex =
              timeslotMap[DateFormat('H:m').format(session.startTime)] ?? 2;
          int currentClassEndColIndex = timeslotMap[DateFormat('H:m').format(
                  session.endTime.subtract(const Duration(minutes: 30)))] ??
              2;

          for (int y = 0; y < 5; y++) {
            defaultSheet.merge(
              CellIndex.indexByColumnRow(
                columnIndex: currentClassStartColIndex,
                rowIndex: currentClassRowIndex + y,
              ),
              CellIndex.indexByColumnRow(
                columnIndex: currentClassEndColIndex,
                rowIndex: currentClassRowIndex + y,
              ),
            );
            var cell = defaultSheet.cell(
              CellIndex.indexByColumnRow(
                columnIndex: currentClassStartColIndex,
                rowIndex: currentClassRowIndex + y,
              ),
            );
            cell.cellStyle = CellStyle(
              horizontalAlign: HorizontalAlign.Center,
              backgroundColorHex: colorMapping[session.course.courseCode]!,
            );
            if (y == 0) {
              cell.value = session.course.courseCode;
            } else if (y == 1) {
              cell.value = session.course.courseDescription;
            } else if (y == 2) {
              String classType = "";
              if (session.classType == ClassType.lecture) {
                classType = "(L)";
              } else if (session.classType == ClassType.tutorial) {
                classType = "(T)";
              } else if (session.classType == ClassType.practical) {
                classType = "(P)";
              } else if (session.classType == ClassType.blended) {
                classType = "(B)";
              }
              cell.value =
                  "${DateFormat('h:mma').format(session.startTime)}-${DateFormat('h:mma').format(session.endTime)} $classType";
            } else if (y == 3) {
              cell.value = session.course.lecturer.name;
            } else {
              cell.value = "";
            }
          }
        }
      });
      currentRow = (progNames.length * 5) + currentRow;
    });

    saveExcel(xlsx);
  }

  Sheet timetableRowHeader(Sheet defaultSheet, int currentRow) {
    // Timetable Header Row
    var cell = defaultSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    cell.value = "DAY/TIME";
    cell.cellStyle =
        CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);
    cell = defaultSheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    cell.value = "PROG";
    cell.cellStyle =
        CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);
    DateTime startDT = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, currentRow, 0);
    for (int x = 1; x <= 12; x++) {
      DateTime dt1 = startDT.add(Duration(hours: x - 1));
      DateTime dt2 = startDT.add(Duration(hours: (x + 1) - 1));
      String value =
          "${DateFormat('hh:mm a').format(dt1)}-${DateFormat('hh:mm a').format(dt2)}";
      defaultSheet.merge(
        CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: (x * 2)),
        CellIndex.indexByColumnRow(
            rowIndex: currentRow, columnIndex: (x * 2) + 1),
      );
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              rowIndex: currentRow, columnIndex: (x * 2)))
          .value = value;
      defaultSheet
              .cell(CellIndex.indexByColumnRow(
                  rowIndex: currentRow, columnIndex: (x * 2)))
              .cellStyle =
          CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);
    }
    return defaultSheet;
  }

  void saveExcel(Excel xlsx) {
    // TODO save in selected folder
    var fileByte = xlsx.save();

    File(Path.join("/home/jazchan/Work/Tarc/fyp/testXlsx/testData.xlsx"))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileByte!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appTitle),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Wrap(
              runSpacing: 10,
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CourseScreen(),
                      ),
                    );
                  },
                  child: const Text("To course screen"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LecturerScreen(),
                      ),
                    );
                  },
                  child: const Text("To lecturer screen"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProgrammeScreen(),
                      ),
                    );
                  },
                  child: const Text("To programme screen"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VenueScreen(),
                      ),
                    );
                  },
                  child: const Text("To venue screen"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageTimeslotScreen(),
                      ),
                    );
                  },
                  child: const Text("Manage timeslot"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    EasyLoading.show(status: "Loading from last saved");
                    await loadGeneratedTimetable();
                  },
                  child: const Text("Load last saved timetable"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    resetFilter();
                    EasyLoading.show(status: "Generating...");

                    List<Course> courses =
                        await CourseRepository.retrieveCourses();
                    List<Venue> venues = await VenueRepository.retrieveVenues();

                    await generateTimetable(courses, venues);

                    refreshTimetable();
                    generatedTimetable = true;

                    EasyLoading.showSuccess("Generated timetable!");
                  },
                  child: const Text("Generate timetable"),
                ),
                generatedTimetable
                    ? ElevatedButton(
                        onPressed: () {
                          EasyLoading.show(status: "Optimizing...");

                          optimizeTimetable();
                        },
                        child: const Text("Optimize table"),
                      )
                    : Container(),
                generatedTimetable
                    ? ElevatedButton(
                        onPressed: () async {
                          EasyLoading.show(status: "Saving timtable...");
                          await saveGeneratedTimetable();
                        },
                        child: const Text("Save generated timetable"),
                      )
                    : Container(),
                generatedTimetable
                    ? ElevatedButton(
                        onPressed: () {
                          EasyLoading.show(status: "Exporting timtable...");
                          createExcelFile();
                          EasyLoading.showSuccess("test complete");
                        },
                        child: const Text("Export generated timetable"),
                      )
                    : Container(),
              ],
            ),
            sessions.isNotEmpty
                ? DropdownButton(
                    value: currentFilterType,
                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Text("All"),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text("Venue"),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text("Course"),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text("Programme"),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text("Lecturer"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value == 0) {
                          refreshTimetable();
                        }
                        currentFilterType = value ?? 0;
                      });
                    },
                  )
                : Container(),
            const SizedBox(
              height: 15,
            ),
            filterTypeDD() ?? Container(),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: WeekView(
                showLiveTimeLineInAllDays: true,
                heightPerMinute: 1.5,
                eventTileBuilder:
                    (date, events, boundary, startDuration, endDuration) {
                  CalendarEventData event = events[0];
                  bool gotClash =
                      event.event.toString().split("&")[2].toLowerCase() ==
                          "true";
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      color:
                          gotClash ? Colors.red[400] : Colors.deepPurple[400],
                    ),
                    child: Tooltip(
                      message:
                          "Course Code: ${event.title} | Class Type , Venue: ${event.event.toString().split("&")[0]}"
                          " | Programme, Lecturer: ${event.event.toString().split("&")[1]}",
                      child: OverflowBox(
                        maxHeight: double.infinity,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Center(
                              child: Text(
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                event.title,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                event.event.toString().split("&")[0],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                event.event.toString().split("&")[1],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
