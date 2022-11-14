import 'package:flutter/material.dart';
import 'package:timetable_management_system/model/course.dart';
import 'package:timetable_management_system/model/lecturer.dart';
import 'package:timetable_management_system/model/programme.dart';
import 'package:timetable_management_system/repository/course_repository.dart';
import 'package:timetable_management_system/repository/lecturer_repository.dart';
import 'package:timetable_management_system/repository/programme_repository.dart';
import 'package:timetable_management_system/utility/class_type.dart';
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
    for (int x = 0; x < 6 * 2; x++) {
      lessonHoursDuration.add((x + 1) * 0.5);
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
                  onPressed: () {},
                  child: const Text("btn txt"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("btn txt"),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: SizedBox(
                      height: 600,
                      child: FutureBuilder(
                        future: CourseRepository.retrieveCourses(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return Container();
                          }
                          if (!snapshot.hasData) return Container();
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              Course course = snapshot.data![index];
                              return Container(
                                decoration: index % 2 != 0
                                    ? const BoxDecoration(color: Colors.black12)
                                    : null,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${index + 1}. ${course.courseCode}"),
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
                                                    if (snapshot
                                                            .connectionState !=
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
                                                            onPressed:
                                                                () async {
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
                                                      child: Text(
                                                          "Confirm Delete?"),
                                                    ),
                                                    const SizedBox(
                                                      height: 50,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        ElevatedButton(
                                                          style:
                                                              const ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStatePropertyAll(
                                                              Colors.red,
                                                            ),
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                            context,
                                                          ),
                                                          child:
                                                              const Text("NO"),
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            removeCourse(
                                                              course.id!,
                                                            );
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text("YES"),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          icon:
                                              const Icon(Icons.delete_forever),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("btn 1"),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("btn 2"),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("btn 3"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
