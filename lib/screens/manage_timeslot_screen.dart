import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:intl/intl.dart';
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
                columnSpacing: 0,
                minWidth: 600,
                columns: List.generate(29, (index) {
                  if (index == 0) {
                    return const DataColumn2(
                      label: Text("Day/Hour"),
                      size: ColumnSize.L,
                    );
                  }
                  return const DataColumn2(
                    label: Text("Header"),
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
                    GFToast.showToast("Cells reseted!", context);
                  });
                },
                child: const Text("Reset"),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Save"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
