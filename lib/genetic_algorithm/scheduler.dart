import 'dart:isolate';
import 'dart:math';

import 'package:timetable_management_system/genetic_algorithm/genetic_algorithm.dart';
import 'package:timetable_management_system/genetic_algorithm/optimize_isolate_model.dart';
import 'package:timetable_management_system/genetic_algorithm/population.dart';
import 'package:timetable_management_system/model/class_session.dart';
import 'package:timetable_management_system/model/course.dart';
import 'package:timetable_management_system/model/timeslot.dart';
import 'package:timetable_management_system/model/venue.dart';

class Scheduler {
  GeneticAlgorithm ga = GeneticAlgorithm();
  Random rm = Random();
  int startHour = 8;

  void initializeInitialTimetable(
    List<Course> courses,
    int dayPeriod,
    int startHourInt,
    int chromosomeCount,
    List<Venue> venues,
    List<TimeSlot> deactivatedSlots,
  ) {
    startHour = startHourInt;
    // Get timeslot
    DateTime dayStartTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, startHour);
    int lessonDayPeriod = dayPeriod;
    List<TimeSlot> timeslots = [];
    Map<String, int> tsMap = {};
    for (int i = 0; i < lessonDayPeriod * 2; i++) {
      DateTime startTime = dayStartTime;
      startTime = startTime.add(Duration(minutes: 30 * i));
      timeslots.add(
        TimeSlot(
          i + 1,
          startTime,
          startTime.add(
            const Duration(minutes: 30),
          ),
        ),
      );
      DateTime thisDT = dayStartTime.add(Duration(minutes: 30 * i));
      tsMap.addAll({
        "${thisDT.hour}:${thisDT.minute}": i,
      });
    }

    // Set deactivated timeslot
    List<int> deactivatedSlotList = [];
    for (var ts in deactivatedSlots) {
      deactivatedSlotList
          .add(tsMap["${ts.startTime.hour}:${ts.startTime.minute}"]!);
    }

    // Generate initial population
    ga.population.initializePopulation(
      chromosomeCount,
      courses,
      timeslots,
      venues,
      deactivatedSlotList,
    );
    ga.population.calcEachFitness();
  }

  void evolve() {
    ga.generationCount++;
    // Do selection
    ga.selection();

    // Do crossover
    ga.crossover();

    // Do mutation
    if (rm.nextInt(10) <= 4) {
      ga.mutation();
    }

    // Rarer mutation with lower rate
    if (rm.nextInt(10) <= 1) {
      ga.mutation();
    }

    ga.addFittestOffspring();

    ga.population.calcEachFitness();
  }

  Population optimize(OptimizeIsolateModel optimizeIsolateModel) {
    do {
      evolve();
    } while (ga.generationCount < optimizeIsolateModel.maxGeneration &&
        ga.population.getFittest().fitness <
            (1 / (1 + optimizeIsolateModel.toleratedConflicts)));
    return ga.population;
  }

  List<ClassSession> fittestTimetableClassSessions() {
    return ga.getChromosomeClassSessions(ga.population.getFittest(), startHour);
  }
}
