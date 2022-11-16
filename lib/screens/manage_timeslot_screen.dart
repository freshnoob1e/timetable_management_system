import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:intl/intl.dart';
import 'package:timetable_management_system/model/timeslot.dart';
import 'package:timetable_management_system/repository/app_setting_repository.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class ManageTimeslotScreen extends StatefulWidget {
  const ManageTimeslotScreen({super.key});

  @override
  State<ManageTimeslotScreen> createState() => _ManageTimeslotScreenState();
}

class _ManageTimeslotScreenState extends State<ManageTimeslotScreen> {
  // {"0,1", DataCell}
  Map<String, DataCell> toggleCells = {};
  List<String> deactivatedCells = [];
  DateTime hourStartDT = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    8,
  );
  Map<String, int> tsMap = {};

  @override
  void initState() {
    for (int x = 0; x < 14 * 2; x++) {
      DateTime thisDT = hourStartDT.add(Duration(minutes: 30 * x));
      tsMap.addAll({
        "${thisDT.hour}:${thisDT.minute}": x + 1,
      });
    }

    getSavedTimeslots();

    super.initState();
  }

  Future getSavedTimeslots() async {
    List<TimeSlot> timeslots =
        await AppSettingRepository.retrieveDeactivatedTimeslots();
    for (var ts in timeslots) {
      int row = ts.startTime.weekday - 1;
      int col = tsMap["${ts.startTime.hour}:${ts.startTime.minute}"]!;
      String cellRowColIndex = "$row,$col";
      toggleCells.addAll({
        cellRowColIndex: DataCell(
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.red[300]),
            ),
            onPressed: () => handleCellBtnOnClick(
              cellRowColIndex,
            ),
            child: Container(),
          ),
        ),
      });
      deactivatedCells.add(cellRowColIndex);
    }
    setState(() {});
  }

  void handleCellBtnOnClick(String cellRowColIndex) {
    Color setColor = Colors.green[300]!;
    if (!deactivatedCells.contains(cellRowColIndex)) {
      deactivatedCells.add(cellRowColIndex);
      setColor = Colors.red[300]!;
    } else {
      deactivatedCells.remove(cellRowColIndex);
    }

    setState(() {
      toggleCells.addAll({
        cellRowColIndex: DataCell(
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(setColor),
            ),
            onPressed: () => handleCellBtnOnClick(
              cellRowColIndex,
            ),
            child: Container(),
          ),
        ),
      });
    });
  }

  Future handleSaveOnClick() async {
    List<TimeSlot> deactivatedTimeslots = [];
    for (String rowCell in deactivatedCells) {
      final splitted = rowCell.split(",");

      DateTime d = DateTime.now();
      d = DateTime(d.year, d.month, d.day, 8, 0);
      DateTime sundayD = d.subtract(Duration(days: d.weekday));
      DateTime cellStartDT =
          sundayD.add(Duration(days: int.parse(splitted[0]) + 1));
      cellStartDT = cellStartDT.add(
        Duration(
          minutes: 30 * (int.parse(splitted[1]) - 1),
        ),
      );
      DateTime cellEndDT = cellStartDT.add(
        const Duration(
          minutes: 30,
        ),
      );

      deactivatedTimeslots.add(
        TimeSlot(null, cellStartDT, cellEndDT),
      );
    }

    await AppSettingRepository.updateDeactivatedTimeslots(deactivatedTimeslots);
    EasyLoading.showSuccess("Saved Successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.manageTimeslotABTitle),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: SizedBox(
              height: 800,
              child: DataTable2(
                border: const TableBorder(
                  verticalInside: BorderSide(width: 0.5),
                  horizontalInside: BorderSide(width: 0.5),
                  bottom: BorderSide(width: 0.5),
                  left: BorderSide(width: 0.5),
                  right: BorderSide(width: 0.5),
                ),
                columnSpacing: 0,
                minWidth: 600,
                columns: List.generate(29, (index) {
                  if (index == 0) {
                    return const DataColumn2(
                      label: Text("Day/Hour"),
                      size: ColumnSize.L,
                    );
                  }
                  if (index % 2 != 0) {
                    DateTime currentHour =
                        hourStartDT.add(Duration(minutes: 30 * (index - 1)));
                    String headerText =
                        "${currentHour.hour.toString().padLeft(2, "0")}:${currentHour.minute.toString().padLeft(2, "0")}";
                    return DataColumn2(
                      label: Text(headerText),
                      size: ColumnSize.M,
                    );
                  }
                  return const DataColumn2(
                    label: Text(""),
                    size: ColumnSize.M,
                  );
                }),
                rows: List.generate(
                  7,
                  (rowIndex) {
                    DateTime todayDT = DateTime.now();
                    DateTime mondayDT = todayDT.subtract(
                      Duration(days: todayDT.weekday - 1),
                    );

                    return DataRow2(
                      cells: List.generate(
                        29,
                        (cellIndex) {
                          if (cellIndex == 0) {
                            return DataCell(
                              Text(
                                DateFormat('EEEE').format(
                                  mondayDT.add(
                                    Duration(days: rowIndex),
                                  ),
                                ),
                              ),
                            );
                          }
                          toggleCells.putIfAbsent(
                            "$rowIndex,$cellIndex",
                            () => DataCell(
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.green[300]),
                                ),
                                onPressed: () => handleCellBtnOnClick(
                                  "$rowIndex,$cellIndex",
                                ),
                                child: Container(),
                              ),
                            ),
                          );
                          return toggleCells["$rowIndex,$cellIndex"]!;
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    toggleCells = {};
                    deactivatedCells = [];
                  });
                  getSavedTimeslots().then((value) {
                    GFToast.showToast("Cells reseted!", context);
                  });
                },
                child: const Text("Reset"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    toggleCells = {};
                    deactivatedCells = [];
                    GFToast.showToast("Cells Cleared!", context);
                  });
                },
                child: const Text("Clear All"),
              ),
              ElevatedButton(
                onPressed: () {
                  EasyLoading.show(status: "Saving...");
                  handleSaveOnClick();
                },
                child: const Text("Save"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
