import 'package:flutter/material.dart';
import 'package:timetable_management_system/model/venue.dart';
import 'package:timetable_management_system/repository/venue_repository.dart';
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

  @override
  void dispose() {
    newVenueNameController.dispose();
    newVenueCapacityController.dispose();
    super.dispose();
  }

  List<Widget> newVenueDialogForm() {
    return [
      // Venue's name
      TextFormField(
        controller: newVenueNameController,
        decoration: const InputDecoration(
          hintText: "Venue's name (e.x. D101)",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a name";
          }
          return null;
        },
      ),
      TextFormField(
        controller: newVenueCapacityController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "Venue's capacity (e.x. 40)",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          if (int.tryParse(value) == null) {
            return "Please enter a valid number";
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

  Future<void> addVenue() async {
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

  Future<void> removeVenue(int venueId) async {
    await VenueRepository.deleteVenue(venueId);
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
                        future: VenueRepository.retrieveVenues(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${index + 1}. ${venue.venueName}"),
                                    IconButton(
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Column(
                                              children: [
                                                const Center(
                                                  child:
                                                      Text("Confirm Delete?"),
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
