import 'package:flutter/material.dart';
import 'package:timetable_management_system/model/lecturer.dart';
import 'package:timetable_management_system/repository/lecturer_repository.dart';
import 'package:timetable_management_system/utility/csvReader/timetable_csv_reader.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class LecturerScreen extends StatefulWidget {
  const LecturerScreen({super.key});

  @override
  State<LecturerScreen> createState() => _LecturerScreenState();
}

class _LecturerScreenState extends State<LecturerScreen> {
  final GlobalKey<FormState> _newLecturerFormKey = GlobalKey<FormState>();
  final newLectNameController = TextEditingController();
  final GlobalKey<FormState> _editLecturerFormKey = GlobalKey<FormState>();
  final editLectNameController = TextEditingController();

  @override
  void dispose() {
    newLectNameController.dispose();
    editLectNameController.dispose();
    super.dispose();
  }

  List<Widget> newLectDialogForm() {
    return [
      // Lecturer's name
      TextFormField(
        controller: newLectNameController,
        decoration: const InputDecoration(
          hintText: "Lecturer's name (e.x. Mr Thomas Tan Ah Kao)",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a name";
          }
          return null;
        },
      ),
    ];
  }

  Future<List<Widget>> editLectDialogForm(int lectID) async {
    Lecturer editLect = await LecturerRepository.retrieveLecturerById(lectID);
    editLectNameController.text = editLect.name;
    return [
      // Lecturer's name
      TextFormField(
        controller: editLectNameController,
        decoration: const InputDecoration(
          hintText: "Lecturer's name (e.x. Mr Thomas Tan Ah Kao)",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a name";
          }
          return null;
        },
      ),
    ];
  }

  Future addLecturer() async {
    if (!_newLecturerFormKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    await LecturerRepository.insertLecturer(
      Lecturer(null, newLectNameController.text),
    );
    setState(() {});
    navigator.pop();
    newLectNameController.clear();
  }

  Future updateLecturer(int lectID) async {
    if (!_editLecturerFormKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    await LecturerRepository.updateLecturer(
      Lecturer(lectID, editLectNameController.text),
    );
    setState(() {});
    navigator.pop();
    editLectNameController.clear();
  }

  Future removeLecturer(int lecturerId) async {
    await LecturerRepository.deleteLecturer(lecturerId);
    setState(() {});
  }

  Future<List<dynamic>> getColumn() async {
    try {
      return await TimetableCSVReader.getCSVColumn("Lecturer");
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future addListOfLecturer(List<String> lecturerNames) async {
    lecturerNames = lecturerNames.toSet().toList();
    for (String lectName in lecturerNames) {
      await LecturerRepository.insertLecturer(
        Lecturer(null, lectName),
      );
    }
    setState(() {});
  }

  Future importLecturers() async {
    List<dynamic> dataList = await getColumn();
    List<String> processedDataList = [];

    for (var data in dataList) {
      processedDataList.add(data.toString());
    }

    await deleteAllLecturer();
    await addListOfLecturer(processedDataList);
  }

  Future deleteAllLecturer() async {
    await LecturerRepository.deleteAllLecturer();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.lecturerABTitle),
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
                            key: _newLecturerFormKey,
                            child: Column(children: [
                              ...newLectDialogForm(),
                              ElevatedButton(
                                onPressed: () async {
                                  await addLecturer();
                                },
                                child: const Text("Add Lecturer"),
                              ),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text("Add New Lecturer"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<dynamic> dataList = await getColumn();
                    List<String> processedDataList = [];

                    for (var data in dataList) {
                      processedDataList.add(data.toString());
                    }

                    addListOfLecturer(processedDataList);
                  },
                  child: const Text("Add lecturer from CSV"),
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                  await importLecturers();
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
                  child: const Text("Import lecturer from CSV"),
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
                                "Confirm delete all lecturer?",
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
                                    await deleteAllLecturer();
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
                  child: const Text("Delete all lecturer from list"),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: SizedBox(
                height: 600,
                child: FutureBuilder(
                  future: LecturerRepository.retrieveLecturers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Container();
                    }
                    if (!snapshot.hasData) return Container();
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Lecturer lect = snapshot.data![index];
                        return Container(
                          decoration: index % 2 != 0
                              ? const BoxDecoration(color: Colors.black12)
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${index + 1}. ${lect.name}"),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: FutureBuilder(
                                            future: editLectDialogForm(
                                              lect.id!,
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
                                                key: _editLecturerFormKey,
                                                child: Column(
                                                  children: [
                                                    ...snapshot.data!,
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await updateLecturer(
                                                            lect.id!);
                                                      },
                                                      child: const Text(
                                                          "Update Lecturer"),
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
                                                      removeLecturer(
                                                        lect.id!,
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
                            ],
                          ),
                        );
                      },
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
