import 'package:flutter/material.dart';
import 'package:timetable_management_system/model/programme.dart';
import 'package:timetable_management_system/repository/programme_repository.dart';
import 'package:timetable_management_system/utility/csvReader/timetable_csv_reader.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class ProgrammeScreen extends StatefulWidget {
  const ProgrammeScreen({super.key});

  @override
  State<ProgrammeScreen> createState() => _ProgrammeScreenState();
}

class _ProgrammeScreenState extends State<ProgrammeScreen> {
  final GlobalKey<FormState> _newProgrammeFormKey = GlobalKey<FormState>();
  final newProgCodeController = TextEditingController();
  final GlobalKey<FormState> _editProgrammeFormKey = GlobalKey<FormState>();
  final editProgCodeController = TextEditingController();

  @override
  void dispose() {
    newProgCodeController.dispose();
    editProgCodeController.dispose();
    super.dispose();
  }

  List<Widget> newProgDialogForm() {
    return [
      // Programme's code
      TextFormField(
        controller: newProgCodeController,
        decoration: const InputDecoration(
          hintText: "Programme's code (e.x. RSDY1S2)",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a valid code";
          }
          return null;
        },
      ),
    ];
  }

  Future<List<Widget>> editProgDialogForm(int progID) async {
    Programme editProg =
        await ProgrammeRepository.retrieveProgrammeById(progID);
    editProgCodeController.text = editProg.programmeCode;
    return [
      // Programme's code
      TextFormField(
        controller: editProgCodeController,
        decoration: const InputDecoration(
          hintText: "Programme's code (e.x. RSDY1S2)",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a valid code";
          }
          return null;
        },
      ),
    ];
  }

  Future addProgramme() async {
    if (!_newProgrammeFormKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    await ProgrammeRepository.insertProgramme(
      Programme(null, newProgCodeController.text),
    );
    setState(() {});
    navigator.pop();
    newProgCodeController.clear();
  }

  Future updateProgramme(int progID) async {
    if (!_editProgrammeFormKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    await ProgrammeRepository.updateProgramme(
      Programme(progID, editProgCodeController.text),
    );
    setState(() {});
    navigator.pop();
    newProgCodeController.clear();
  }

  Future removeProgramme(int progId) async {
    await ProgrammeRepository.deleteProgramme(progId);
    setState(() {});
  }

  Future<List<dynamic>> getColumn() async {
    try {
      return await TimetableCSVReader.getCSVColumn("Programme");
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future addListOfProgramme(List<String> programmeNames) async {
    programmeNames = programmeNames.toSet().toList();
    for (String progName in programmeNames) {
      await ProgrammeRepository.insertProgramme(
        Programme(null, progName),
      );
    }
    setState(() {});
  }

  Future importProgrammes() async {
    List<dynamic> dataList = await getColumn();
    List<String> processedDataList = [];

    for (var data in dataList) {
      processedDataList.add(data.toString());
    }

    await deleteAllProgramme();
    await addListOfProgramme(processedDataList);
  }

  Future deleteAllProgramme() async {
    await ProgrammeRepository.deleteAllProgrammes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.programmeABTitle),
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
                            key: _newProgrammeFormKey,
                            child: Column(children: [
                              ...newProgDialogForm(),
                              ElevatedButton(
                                onPressed: () async {
                                  await addProgramme();
                                },
                                child: const Text("Add Programme"),
                              ),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text("Add New Programme"),
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

                    addListOfProgramme(processedDataList);
                  },
                  child: const Text("Add programme from CSV"),
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
                                  await importProgrammes();
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
                  child: const Text("Import programme from CSV"),
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
                                "Confirm delete all programme?",
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
                                    await deleteAllProgramme();
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
                  child: const Text("Delete all programme from list"),
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
                  future: ProgrammeRepository.retrieveProgrammes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Container();
                    }
                    if (!snapshot.hasData) return Container();
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Programme prog = snapshot.data![index];
                        return Container(
                          decoration: index % 2 != 0
                              ? const BoxDecoration(color: Colors.black12)
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${index + 1}. ${prog.programmeCode}"),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () => showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: FutureBuilder(
                                                  future: editProgDialogForm(
                                                      prog.id!),
                                                  builder: (
                                                    context,
                                                    snapshot,
                                                  ) {
                                                    if (snapshot
                                                            .connectionState !=
                                                        ConnectionState.done) {
                                                      return Container();
                                                    }
                                                    if (!snapshot.hasData) {
                                                      return Container();
                                                    }
                                                    return Form(
                                                      key:
                                                          _editProgrammeFormKey,
                                                      child: Column(
                                                        children: [
                                                          ...snapshot.data!,
                                                          ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              await updateProgramme(
                                                                  prog.id!);
                                                            },
                                                            child: const Text(
                                                              "Update Programme",
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                      icon: const Icon(Icons.edit)),
                                  IconButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Column(
                                            children: [
                                              const Center(
                                                child: Text(
                                                  "Confirm Delete?",
                                                ),
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
                                                      removeProgramme(
                                                        prog.id!,
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
