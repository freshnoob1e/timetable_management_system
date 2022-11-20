import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:timetable_management_system/model/course.dart';
import 'package:timetable_management_system/model/lecturer.dart';
import 'package:timetable_management_system/model/programme.dart';
import 'package:timetable_management_system/repository/course_repository.dart';
import 'package:timetable_management_system/repository/lecturer_repository.dart';
import 'package:timetable_management_system/repository/programme_repository.dart';
import 'package:timetable_management_system/utility/class_type.dart';
import 'package:timetable_management_system/utility/csvReader/timetable_csv_reader.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  List<double> lessonHoursDuration = [];
  final GlobalKey<FormState> _newCourseFormKey = GlobalKey<FormState>();
  final newCourseCodeController = TextEditingController();
  final newCourseDescController = TextEditingController();
  Map<ClassType, double> newCourseLessonHour = {};
  Lecturer? newCourseLect;
  Programme? newCourseProg;
  final GlobalKey<FormState> _editCourseFormKey = GlobalKey<FormState>();
  final editCourseCodeController = TextEditingController();
  final editCourseDescController = TextEditingController();
  Map<ClassType, double> editCourseLessonHour = {};
  Lecturer? editCourseLect;
  Programme? editCourseProg;

  @override
  void initState() {
    for (int x = 0; x < 13; x++) {
      lessonHoursDuration.add((x) * 0.5);
    }
    super.initState();
  }

  @override
  void dispose() {
    newCourseCodeController.dispose();
    newCourseDescController.dispose();
    editCourseCodeController.dispose();
    editCourseDescController.dispose();
    super.dispose();
  }

  Future<List<Widget>> newCourseDialogForm() async {
    List<Lecturer> lects = await LecturerRepository.retrieveLecturers();
    List<Programme> progs = await ProgrammeRepository.retrieveProgrammes();
    newCourseLect = lects[0];
    newCourseProg = progs[0];
    for (ClassType ct in ClassType.values) {
      newCourseLessonHour.addAll({ct: lessonHoursDuration[0]});
    }
    return [
      // Course's lecturer
      DropdownButtonFormField(
        value: newCourseLect,
        items: lects.map((Lecturer e) {
          return DropdownMenuItem<Lecturer>(
            value: e,
            child: Text(e.name),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            newCourseLect = value;
          }
        },
      ),
      // Course's programme
      DropdownButtonFormField(
        value: newCourseProg,
        items: progs.map((Programme e) {
          return DropdownMenuItem<Programme>(
            value: e,
            child: Text(e.programmeCode),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            newCourseProg = value;
          }
        },
      ),
      // Course Code
      TextFormField(
        controller: newCourseCodeController,
        decoration: const InputDecoration(
          hintText: "Course Code (e.x. BAIT1234)",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a valid course code";
          }
          return null;
        },
      ),
      // Course description
      TextFormField(
        controller: newCourseDescController,
        decoration: const InputDecoration(
          hintText: "Course Description",
        ),
      ),
      // Course lesson hour
      ...List.generate(ClassType.values.length, (index) {
        return DropdownButtonFormField(
          decoration: InputDecoration(
            label: Text(ClassType.values[index].name),
          ),
          value: lessonHoursDuration[0],
          items: lessonHoursDuration.map((e) {
            return DropdownMenuItem<double>(
              value: e,
              child: Text("${e.toString()} hours"),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              newCourseLessonHour[ClassType.values[index]] = value;
            }
          },
        );
      })
    ];
  }

  Future<List<Widget>> editCourseDialogForm(int courseID) async {
    List<Lecturer> lects = await LecturerRepository.retrieveLecturers();
    List<Programme> progs = await ProgrammeRepository.retrieveProgrammes();

    Course editCourse = await CourseRepository.retrieveCourseById(courseID);
    for (Lecturer lect in lects) {
      if (lect.id == editCourse.lecturer.id) {
        editCourseLect = lect;
      }
    }
    for (Programme prog in progs) {
      if (prog.id == editCourse.programmeCode.id) {
        editCourseProg = prog;
      }
    }
    editCourseCodeController.text = editCourse.courseCode;
    editCourseDescController.text = editCourse.courseDescription ?? "";
    editCourse.lessonsHours.forEach((key, value) {
      editCourseLessonHour.addAll({key: value});
    });

    return [
      // Course's lecturer
      DropdownButtonFormField(
        value: editCourseLect,
        items: lects.map((Lecturer e) {
          return DropdownMenuItem<Lecturer>(
            value: e,
            child: Text(e.name),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            editCourseLect = value;
          }
        },
      ),
      // Course's programme
      DropdownButtonFormField(
        value: editCourseProg,
        items: progs.map((Programme e) {
          return DropdownMenuItem<Programme>(
            value: e,
            child: Text(e.programmeCode),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            editCourseProg = value;
          }
        },
      ),
      // Course Code
      TextFormField(
        controller: editCourseCodeController,
        decoration: const InputDecoration(
          hintText: "Course Code (e.x. BAIT1234)",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a valid course code";
          }
          return null;
        },
      ),
      // Course description
      TextFormField(
        controller: editCourseDescController,
        decoration: const InputDecoration(
          hintText: "Course Description",
        ),
      ),
      // Course lesson hour
      ...List.generate(ClassType.values.length, (index) {
        return DropdownButtonFormField(
          decoration: InputDecoration(
            label: Text(
              ClassType.values[index].name,
            ),
          ),
          value: editCourseLessonHour[ClassType.values[index]],
          items: lessonHoursDuration.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text("${e.toString()} hours"),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              editCourseLessonHour[ClassType.values[index]] = value;
            }
          },
        );
      })
    ];
  }

  Future addCourse() async {
    if (!_newCourseFormKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);

    if (newCourseLect == null) return;
    if (newCourseProg == null) return;

    await CourseRepository.insertCourse(
      Course(
        null,
        newCourseLect!,
        newCourseProg!,
        newCourseCodeController.text,
        newCourseDescController.text,
        newCourseLessonHour,
      ),
    );
    setState(() {});
    navigator.pop();
    newCourseCodeController.clear();
    newCourseDescController.clear();
  }

  Future updateCourse(int courseID) async {
    if (!_editCourseFormKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);

    if (editCourseLect == null) return;
    if (editCourseProg == null) return;

    await CourseRepository.updateCourse(
      Course(
        courseID,
        editCourseLect!,
        editCourseProg!,
        editCourseCodeController.text,
        editCourseDescController.text,
        editCourseLessonHour,
      ),
    );
    setState(() {});
    navigator.pop();
    editCourseCodeController.clear();
    editCourseDescController.clear();
  }

  Future removeCourse(int courseId) async {
    await CourseRepository.deleteCourse(courseId);
    setState(() {});
  }

  Future<List<List<dynamic>>> getColumn() async {
    try {
      List<List<dynamic>> listOfColumnsData =
          await TimetableCSVReader.getCSVColumns([
        "Lecturer",
        "Programme",
        "CourseCode",
        "CourseDescription",
        "Lecture",
        "Tutorial",
        "Practical",
        "Blended",
      ]);
      List<dynamic> lectNameList = listOfColumnsData[0];
      List<dynamic> progCodeList = listOfColumnsData[1];
      List<dynamic> courseCodeList = listOfColumnsData[2];
      List<dynamic> courseDescList = listOfColumnsData[3];
      List<dynamic> lectureHourList = listOfColumnsData[4];
      List<dynamic> tutorialHourList = listOfColumnsData[5];
      List<dynamic> practicalHourList = listOfColumnsData[6];
      List<dynamic> blendedHourList = listOfColumnsData[7];
      return [
        lectNameList,
        progCodeList,
        courseCodeList,
        courseDescList,
        lectureHourList,
        tutorialHourList,
        practicalHourList,
        blendedHourList,
      ];
    } catch (e) {
      EasyLoading.showError("Something went wrong...");
      return [];
    }
  }

  Future addListOfCourse(
    List<String> lectNames,
    List<String> progCodes,
    List<String> courseCodes,
    List<String> courseDescs,
    List<String> lectureHours,
    List<String> tutorialHours,
    List<String> practicalHours,
    List<String> blendedHours,
  ) async {
    try {
      List<List<String>> argumentLists = [
        lectNames,
        progCodes,
        courseCodes,
        courseDescs,
        lectureHours,
        tutorialHours,
        practicalHours,
        blendedHours,
      ];
      List<Lecturer> existingLecturers =
          await LecturerRepository.retrieveLecturers();
      List<Programme> existingProgs =
          await ProgrammeRepository.retrieveProgrammes();

      // Check if data has equal row
      bool isValidCSVData = true;
      List<int> listsLength = [];

      for (var list in argumentLists) {
        listsLength.add(list.length);
      }

      if (listsLength.toSet().length != 1) {
        isValidCSVData = false;
      }

      // Check if lecturer and programme code exists in database

      if (isValidCSVData) {
        List<String> existingLectNames = [];
        for (Lecturer lect in existingLecturers) {
          existingLectNames.add(lect.name);
        }
        for (String lectName in lectNames) {
          if (!existingLectNames.contains(lectName)) {
            isValidCSVData = false;
            break;
          }
        }
      }

      if (isValidCSVData) {
        List<String> existingProgCodes = [];
        for (Programme prog in existingProgs) {
          existingProgCodes.add(prog.programmeCode);
        }
        for (String progCode in progCodes) {
          if (!existingProgCodes.contains(progCode)) {
            isValidCSVData = false;
            break;
          }
        }
      }

      // Check if lesson hours data is valid (Not empty and is number)
      if (isValidCSVData) {
        for (int x = 4; x < argumentLists.length; x++) {
          for (String hours in argumentLists[x]) {
            if (hours.isEmpty || double.tryParse(hours) == null) {
              isValidCSVData = false;
              break;
            }
          }
          if (!isValidCSVData) {
            break;
          }
        }
      }

      if (!isValidCSVData) {
        throw Exception("Invalid CSV Data");
      }

      Map<String, Lecturer> lectNameMap = {};
      Map<String, Programme> progNameMap = {};

      for (Lecturer lect in existingLecturers) {
        lectNameMap.addAll({lect.name: lect});
      }
      for (Programme prog in existingProgs) {
        progNameMap.addAll({prog.programmeCode: prog});
      }

      for (int x = 0; x < lectNames.length; x++) {
        Lecturer thisCourseLect = lectNameMap[lectNames[x]]!;
        Programme thisCourseProg = progNameMap[progCodes[x]]!;
        Map<ClassType, double> lessonsHours = {};

        for (int y = 4; y < argumentLists.length; y++) {
          late ClassType currentClassType;
          if (y == 4) {
            currentClassType = ClassType.lecture;
          } else if (y == 5) {
            currentClassType = ClassType.tutorial;
          } else if (y == 6) {
            currentClassType = ClassType.practical;
          } else {
            currentClassType = ClassType.blended;
          }

          lessonsHours
              .addAll({currentClassType: double.parse(argumentLists[y][x])});
        }

        Course newCourse = Course(
          null,
          thisCourseLect,
          thisCourseProg,
          courseCodes[x],
          courseDescs[x],
          lessonsHours,
        );
        await CourseRepository.insertCourse(newCourse);
      }
      setState(() {});
    } catch (e) {
      EasyLoading.showError("Something went wrong...");
    }
  }

  Future importCourses() async {
    List<List<dynamic>> dataLists = await getColumn();
    List<List<String>> processedList = List.generate(
      dataLists.length,
      (index) => List.generate(
        dataLists[index].length,
        (i) => dataLists[index][i].toString(),
      ),
    );

    await deleteAllCourse();
    await addListOfCourse(
      processedList[0],
      processedList[1],
      processedList[2],
      processedList[3],
      processedList[4],
      processedList[5],
      processedList[6],
      processedList[7],
    );
  }

  Future deleteAllCourse() async {
    await CourseRepository.deleteAllCourse();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.courseABTitle),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Form(
                            key: _newCourseFormKey,
                            child: FutureBuilder(
                              future: newCourseDialogForm(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  return Container();
                                }
                                if (!snapshot.hasData) return Container();
                                return Column(children: [
                                  ...snapshot.data!,
                                  ElevatedButton(
                                    onPressed: () async {
                                      await addCourse();
                                    },
                                    child: const Text("Add Course"),
                                  ),
                                ]);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text("Add New Course"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<List<dynamic>> dataLists = await getColumn();
                    List<List<String>> processedList = List.generate(
                      dataLists.length,
                      (index) => List.generate(
                        dataLists[index].length,
                        (i) => dataLists[index][i].toString(),
                      ),
                    );

                    await addListOfCourse(
                      processedList[0],
                      processedList[1],
                      processedList[2],
                      processedList[3],
                      processedList[4],
                      processedList[5],
                      processedList[6],
                      processedList[7],
                    );
                  },
                  child: const Text("Add course from CSV"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Column(children: [
                          const Center(
                            child: Text(
                              "This will overwrite your existing list, confirm continue?",
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("NO"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  NavigatorState navigator =
                                      Navigator.of(context);
                                  await importCourses();
                                  navigator.pop();
                                },
                                child: const Text("YES"),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    );
                  },
                  child: const Text("Import course from CSV"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Colors.red[300],
                    ),
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Column(
                          children: [
                            const Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                "Confirm delete all course?",
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                      Colors.red[300],
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("NO"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    NavigatorState navigator =
                                        Navigator.of(context);
                                    await deleteAllCourse();
                                    navigator.pop();
                                  },
                                  child: const Text("YES"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text("Delete all course from list"),
                ),
              ],
            ),
            const SizedBox(
              height: 35,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                width: double.infinity,
                child: FutureBuilder(
                  future: CourseRepository.retrieveCourses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Container();
                    }
                    if (!snapshot.hasData) return Container();
                    return SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("Course Code")),
                          DataColumn(label: Text("Course Description")),
                          DataColumn(label: Text("Lecturer")),
                          DataColumn(label: Text("Programme")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: List.generate(snapshot.data!.length, (index) {
                          Course course = snapshot.data![index];
                          return DataRow(cells: [
                            DataCell(
                                Text("${index + 1}. ${course.courseCode}")),
                            DataCell(Text(course.courseDescription ?? "")),
                            DataCell(Text(course.lecturer.name)),
                            DataCell(Text(course.programmeCode.programmeCode)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: FutureBuilder(
                                            future: editCourseDialogForm(
                                              course.id!,
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState !=
                                                  ConnectionState.done) {
                                                return Container();
                                              }
                                              if (!snapshot.hasData) {
                                                return Container();
                                              }
                                              return Form(
                                                key: _editCourseFormKey,
                                                child: Column(
                                                  children: [
                                                    ...snapshot.data!,
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await updateCourse(
                                                            course.id!);
                                                      },
                                                      child: const Text(
                                                          "Update Course"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Column(
                                            children: [
                                              const Center(
                                                child: Text("Confirm Delete?"),
                                              ),
                                              const SizedBox(
                                                height: 50,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                    style: const ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStatePropertyAll(
                                                        Colors.red,
                                                      ),
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                      context,
                                                    ),
                                                    child: const Text("NO"),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      removeCourse(
                                                        course.id!,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("YES"),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    icon: const Icon(Icons.delete_forever),
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
