import 'package:flutter/material.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class ManageTimeslotScreen extends StatefulWidget {
  const ManageTimeslotScreen({super.key});

  @override
  State<ManageTimeslotScreen> createState() => _ManageTimeslotScreenState();
}

class _ManageTimeslotScreenState extends State<ManageTimeslotScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.manageTimeslotABTitle),
      ),
    );
  }
}
