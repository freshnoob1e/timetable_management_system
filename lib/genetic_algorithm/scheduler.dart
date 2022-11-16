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
    DateTime sundayStartTime = dayStartTime.subtract(
      Duration(days: dayStartTime.weekday),
    );
    int lessonDayPeriod = dayPeriod;
    List<TimeSlot> timeslots = [];
    Map<String, int> tsMap = {};
    List<int> endOfDayTSIndexes = [];
    for (int day = 1; day <= 7; day++) {
      DateTime startTime = sundayStartTime.add(
        Duration(days: day),
      );
      for (int i = 0; i < lessonDayPeriod * 2; i++) {
        int currentIndex =
            (i + (lessonDayPeriod * 2 * (day - 1))) + 1 + (day - 1);
        DateTime thisStartTime = startTime.add(Duration(minutes: 30 * i));
        timeslots.add(
          TimeSlot(
            currentIndex,
            thisStartTime,
            thisStartTime.add(
              const Duration(minutes: 30),
            ),
          ),
        );
        tsMap.addAll({
          "${thisStartTime.hour}:${thisStartTime.minute};${thisStartTime.day}/${thisStartTime.month}":
              currentIndex,
        });
        // Add deactivated timeslot for end of day
        if (i == (lessonDayPeriod * 2) - 1) {
          timeslots.add(
            TimeSlot(
              currentIndex,
              thisStartTime.add(
                const Duration(minutes: 30),
              ),
              thisStartTime.add(
                const Duration(minutes: 30 * 2),
              ),
            ),
          );
          endOfDayTSIndexes.add(currentIndex);
        }
      }
    }

    // Set deactivated timeslot
    List<int> deactivatedSlotList = [];
    for (var ts in deactivatedSlots) {
      String key =
          "${ts.startTime.hour}:${ts.startTime.minute};${ts.startTime.day}/${ts.startTime.month}";
      if (!tsMap.containsKey(key)) {
        continue;
      }
      deactivatedSlotList.add(tsMap[key]! - 1);
    }

    // Generate initial population
    ga.population.initializePopulation(
      chromosomeCount,
      courses,
      timeslots,
      venues,
      deactivatedSlotList,
      endOfDayTSIndexes,
      lessonDayPeriod * 2,
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
