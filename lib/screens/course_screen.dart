import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:timetable_management_system/utility/values/strings.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
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
                  onPressed: () {},
                  child: const Text("btn txt"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("btn txt"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("btn txt"),
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
                    child: Column(
                      children: const [
                        Text("Course 1"),
                        Text("Course 2"),
                        Text("Course 3"),
                        Text("Course 4"),
                      ],
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
