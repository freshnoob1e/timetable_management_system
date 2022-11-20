import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:timetable_management_system/model/venue.dart';
import 'package:timetable_management_system/repository/venue_repository.dart';
import 'package:timetable_management_system/utility/csvReader/timetable_csv_reader.dart';
import 'package:timetable_management_system/utility/values/strings.dart';
import 'package:timetable_management_system/utility/venue_type.dart';

class VenueScreen extends StatefulWidget {
  const VenueScreen({super.key});

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen> {
  final GlobalKey<FormState> _newVenueFormKey = GlobalKey<FormState>();
  final newVenueNameController = TextEditingController();
  final newVenueCapacityController = TextEditingController();
  int newVenueType = 0;
  final GlobalKey<FormState> _editVenueFormKey = GlobalKey<FormState>();
  final editVenueNameController = TextEditingController();
  final editVenueCapacityController = TextEditingController();
  int editVenueType = 0;

  @override
  void dispose() {
    newVenueNameController.dispose();
    newVenueCapacityController.dispose();
    editVenueNameController.dispose();
    editVenueCapacityController.dispose();
    super.dispose();
  }

  List<Widget> newVenueDialogForm() {
    return [
      // Venue's name
      TextFormField(
        controller: newVenueNameController,
        decoration: const InputDecoration(
          label: Text("Venue Name"),
          hintText: "Venue's name (e.x. D101)",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a name";
          }
          return null;
        },
      ),
      DropdownButtonFormField(
        value: 0,
        items: VenueType.values.map((e) {
          return DropdownMenuItem(
            value: e.index,
            child: Text(e.name),
          );
        }).toList(),
        onChanged: (int? value) {
          if (value != null) {
            newVenueType = value;
          }
        },
      ),
    ];
  }

  Future<List<Widget>> editVenueDialogForm(Venue editVenue) async {
    editVenueNameController.text = editVenue.venueName;
    editVenueCapacityController.text = editVenue.venueCapacity != null
        ? editVenue.venueCapacity.toString()
        : "0";
    for (var vt in VenueType.values) {
      if (vt == editVenue.venueType) {
        editVenueType = vt.index;
        break;
      }
    }
    return [
      // Venue's name
      TextFormField(
        controller: editVenueNameController,
        decoration: const InputDecoration(
          label: Text("Venue Name"),
          hintText: "Venue's name (e.x. D101)",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a name";
          }
          return null;
        },
      ),
      DropdownButtonFormField(
        value: editVenueType,
        items: VenueType.values.map((e) {
          return DropdownMenuItem(
            value: e.index,
            child: Text(e.name),
          );
        }).toList(),
        onChanged: (int? value) {
          if (value != null) {
            editVenueType = value;
          }
        },
      ),
    ];
  }

  Future addVenue() async {
    if (!_newVenueFormKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    await VenueRepository.insertVenue(
      Venue(
        null,
        newVenueNameController.text,
        int.tryParse(newVenueCapacityController.text),
        VenueType.values[newVenueType],
      ),
    );
    setState(() {});
    navigator.pop();
    newVenueNameController.clear();
    newVenueCapacityController.clear();
    newVenueType = 0;
  }

  Future updateVenue(int venueID) async {
    if (!_editVenueFormKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    await VenueRepository.updateVenue(
      Venue(
        venueID,
        editVenueNameController.text,
        int.tryParse(editVenueCapacityController.text),
        VenueType.values[editVenueType],
      ),
    );
    setState(() {});
    navigator.pop();
    editVenueNameController.clear();
    editVenueCapacityController.clear();
    editVenueType = 0;
  }

  Future removeVenue(int venueId) async {
    await VenueRepository.deleteVenue(venueId);
    setState(() {});
  }

  Future<List<List<dynamic>>> getColumn() async {
    try {
      List<List<dynamic>> listOfColumnsData =
          await TimetableCSVReader.getCSVColumns(["VenueName", "VenueType"]);
      List<dynamic> venueNameList = listOfColumnsData[0];
      List<dynamic> venueTypeList = listOfColumnsData[1];
      return [venueNameList, venueTypeList];
    } catch (e) {
      EasyLoading.showError("Something went wrong...");
      return [];
    }
  }

  Future addListOfVenue(
    List<String> venueNames,
    List<String> venueTypes,
  ) async {
    if (venueNames.length != venueTypes.length) {
      throw Exception("Invalid CSV Data");
    }
    // venueName = venueName.toSet().toList();
    for (int x = 0; x < venueNames.length; x++) {
      VenueType venueType = VenueType.lecture;
      for (var type in VenueType.values) {
        if (type.name == venueTypes[x]) {
          venueType = type;
        }
      }
      Venue newVenue = Venue(null, venueNames[x], null, venueType);
      await VenueRepository.insertVenue(newVenue);
    }
    setState(() {});
  }

  Future importVenues() async {
    List<List<dynamic>> dataLists = await getColumn();
    List<String> processedVenueNameList = List.generate(
      dataLists[0].length,
      (index) => dataLists[0][index].toString(),
    );
    List<String> processedVenueTypeList = List.generate(
      dataLists[1].length,
      (index) => dataLists[1][index].toString(),
    );

    await deleteAllVenue();
    await addListOfVenue(
      processedVenueNameList,
      processedVenueTypeList,
    );
  }

  Future deleteAllVenue() async {
    await VenueRepository.deleteAllVenue();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.venueABTitle),
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
                            key: _newVenueFormKey,
                            child: Column(children: [
                              ...newVenueDialogForm(),
                              ElevatedButton(
                                onPressed: () async {
                                  await addVenue();
                                },
                                child: const Text("Add Venue"),
                              ),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text("Add New Venue"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<List<dynamic>> dataLists = await getColumn();
                    List<String> processedVenueNameList = List.generate(
                      dataLists[0].length,
                      (index) => dataLists[0][index].toString(),
                    );
                    List<String> processedVenueTypeList = List.generate(
                      dataLists[1].length,
                      (index) => dataLists[1][index].toString(),
                    );

                    addListOfVenue(
                      processedVenueNameList,
                      processedVenueTypeList,
                    );
                  },
                  child: const Text("Add venue from CSV"),
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
                                  await importVenues();
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
                  child: const Text("Import venue from CSV"),
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
                                "Confirm delete all venue?",
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
                                    await deleteAllVenue();
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
                  child: const Text("Delete all venue from list"),
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
                  future: VenueRepository.retrieveVenues(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Container();
                    }
                    if (!snapshot.hasData) return Container();
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Venue venue = snapshot.data![index];
                        return Container(
                          decoration: index % 2 != 0
                              ? const BoxDecoration(color: Colors.black12)
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${index + 1}. ${venue.venueName}"),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Form(
                                            key: _editVenueFormKey,
                                            child: FutureBuilder(
                                              future: editVenueDialogForm(
                                                venue,
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState !=
                                                    ConnectionState.done) {
                                                  return Container();
                                                }
                                                if (!snapshot.hasData) {
                                                  return Container();
                                                }
                                                return Column(
                                                  children: [
                                                    ...snapshot.data!,
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await updateVenue(
                                                            venue.id!);
                                                      },
                                                      child: const Text(
                                                          "Update Venue"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
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
                                                      removeVenue(
                                                        venue.id!,
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
