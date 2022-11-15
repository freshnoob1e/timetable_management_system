import 'dart:math';

import 'package:timetable_management_system/genetic_algorithm/chromosome.dart';
import 'package:timetable_management_system/genetic_algorithm/gene.dart';
import 'package:timetable_management_system/model/class_session.dart';
import 'package:timetable_management_system/model/course.dart';
import 'package:timetable_management_system/model/timeslot.dart';
import 'package:timetable_management_system/model/venue.dart';
import 'package:timetable_management_system/utility/class_type.dart';
import 'package:timetable_management_system/utility/venue_type.dart';

class Population {
  int popSize = 0;
  List<Chromosome> chromosomes = [];
  List<ClassSession> classSessions = [];
  late List<TimeSlot> timeslots;
  int timeslotLength = 0;
  double fittestFitness = 0;
  Random rm = Random();

  // Initialize population
  void initializePopulation(
    int populationSize,
    List<Course> courses,
    List<TimeSlot> timeslotslist,
    List<Venue> venues,
  ) {
    timeslots = timeslotslist;
    timeslotLength = timeslots.length;

    popSize = populationSize;

    int i = 0;
    for (Course course in courses) {
      // Create Lecture session for each lesson according to master course timetable detail
      course.lessonsHours.forEach((key, value) {
        // Create session only when value is greater than 0
        if (value > 0) {
          // Get usable venues depending on lesson type and venue type
          List<Venue> usableVenue = [];
          for (Venue venue in venues) {
            if (venue.venueType == VenueType.lecture) {
              if (key == ClassType.lecture || key == ClassType.blended) {
                usableVenue.add(venue);
              }
            } else if (venue.venueType == VenueType.tutorial) {
              if (key == ClassType.blended || key == ClassType.tutorial) {
                usableVenue.add(venue);
              }
            } else if (venue.venueType == VenueType.laboratory) {
              if (key == ClassType.practical) {
                usableVenue.add(venue);
              }
            }
          }

          // Create session with randomly selected timeslot
          // If timeslot is not long enough, loop until true
          bool slotCreated = false;
          while (!slotCreated) {
            // Get initial random timeslot
            int randTimeSlotIndex = rm.nextInt(timeslotLength);

            //Check if timeslot is long enough
            int slotsRequired = value ~/ 0.5;
            int availableSlots = (randTimeSlotIndex - timeslotLength).abs() + 1;

            // If slot is enough to host lesson, add clss session
            if (availableSlots >= slotsRequired) {
              ++i;
              classSessions.add(
                ClassSession(
                  i,
                  course,
                  key,
                  usableVenue[rm.nextInt(usableVenue.length)],
                  timeslots[randTimeSlotIndex].startTime,
                  timeslots[randTimeSlotIndex].startTime.add(
                        Duration(minutes: 30 * slotsRequired),
                      ),
                ),
              );
              slotCreated = true;
            }
          }
        }
      });
    }

    // Create chromosome base on defined population size
    for (int i = 0; i < popSize; i++) {
      List<Gene> genes = [];
      for (ClassSession session in classSessions) {
        // Create new gene base on class sessions
        genes.add(shiftRandomSlot(session, timeslotLength));
      }
      chromosomes.add(Chromosome(genes));
    }
  }

  Gene shiftRandomSlot(ClassSession classSession, int timeSlotLength) {
    Random rm = Random();
    int requiredSlot =
        classSession.course.lessonsHours[classSession.classType]! ~/ 0.5;
    bool slotFound = false;
    Gene newGene = Gene([]);

    while (!slotFound) {
      int randStartSlot = rm.nextInt(timeSlotLength);

      if ((timeSlotLength - randStartSlot) >= requiredSlot) {
        slotFound = true;
        for (int i = 0; i < requiredSlot; i++) {
          newGene.occupiedSlot.add(randStartSlot + i);
        }
      }
    }

    return newGene;
  }

  // Get fittest individual
  Chromosome getFittest() {
    double maxFit = 0;
    int maxFitIndex = 0;
    for (int i = 0; i < chromosomes.length; i++) {
      if (maxFit < chromosomes[i].fitness) {
        maxFit = chromosomes[i].fitness;
        maxFitIndex = i;
      }
    }
    fittestFitness = chromosomes[maxFitIndex].fitness;
    return chromosomes[maxFitIndex];
  }

  int getFittestIndex() {
    double maxFit = 0;
    int maxFitIndex = 0;
    for (int i = 0; i < chromosomes.length; i++) {
      if (maxFit < chromosomes[i].fitness) {
        maxFit = chromosomes[i].fitness;
        maxFitIndex = i;
      }
    }
    fittestFitness = chromosomes[maxFitIndex].fitness;
    return maxFitIndex;
  }

  // Get second fittest individual
  Chromosome getSecondFittest() {
    int maxFit1Index = 0;
    int maxFit2Index = 0;
    for (int i = 0; i < chromosomes.length; i++) {
      if (chromosomes[i].fitness > chromosomes[maxFit1Index].fitness) {
        maxFit2Index = maxFit1Index;
        maxFit1Index = i;
      } else if (chromosomes[i].fitness > chromosomes[maxFit2Index].fitness) {
        maxFit2Index = i;
      }
    }
    return chromosomes[maxFit2Index];
  }

  // Get least fit individual index
  int getLeastFitIndex() {
    double minFitVal = 1;
    int minFitIndex = 0;
    for (int i = 0; i < chromosomes.length; i++) {
      if (minFitVal > chromosomes[i].fitness) {
        minFitVal = chromosomes[i].fitness;
        minFitIndex = i;
      }
    }
    return minFitIndex;
  }

  // Calculate each individual fitness
  void calcEachFitness() {
    for (Chromosome chromosome in chromosomes) {
      chromosome.calcFitness(classSessions);
    }
    getFittest();
  }

  @override
  String toString() {
    return "$chromosomes";
  }
}
