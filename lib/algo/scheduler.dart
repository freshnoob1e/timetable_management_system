import 'dart:math';

import 'package:timetable_management_system/algo/genetic_algorithm.dart';
import 'package:timetable_management_system/model/course.dart';
import 'package:timetable_management_system/model/timeslot.dart';
import 'package:timetable_management_system/model/venue.dart';

void initializeInitialTimetable(
  List<Course> courses,
  int dayPeriod,
  int chromosomeCount,
  List<Venue> venues,
) {
  Random rm = Random();

  // Get timeslot
  DateTime dayStartTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 8);
  int lessonDayPeriod = dayPeriod;
  List<TimeSlot> timeslots = [];
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
  }

  GeneticAlgorithm ga = GeneticAlgorithm();

  // Generate initial population
  ga.population
      .initializePopulation(chromosomeCount, courses, timeslots, venues);
  ga.population.calcEachFitness();

  do {
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

    // TODO remove hard coded condition
  } while (ga.generationCount < 10000000 &&
      ga.population.getFittest().fitness < (1 / (1 + 2)));

  ga.visualizeChromosome(ga.population.getFittest());
}
