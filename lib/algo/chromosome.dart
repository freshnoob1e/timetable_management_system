import 'package:timetable_management_system/algo/gene.dart';
import 'package:timetable_management_system/model/class_session.dart';

class Chromosome {
  double fitness = 0;
  // The number of genes (class sessions)
  int genesLength = 0;
  // The number of time slots
  int slotLength = 0;
  List<Gene> genes;

  Chromosome(
    this.genes,
  ) {
    genesLength = genes.length;
    slotLength = genes[0].occupiedSlot.length;
  }

  Chromosome.clone(Chromosome chromosome) : this(chromosome.genes);

  void calcFitness(List<ClassSession> classSessions) {
    fitness = 0;

    // Timeslot, <Venue/StudentGroup/Lecturer, <ID, [GeneIndex]>>
    Map<int, Map<String, Map<int, List<int>>>> geneSlot = {};

    // Example
    // {
    //   1: {
    //     "venue": {
    //        "D101": [1,3,5]
    //      },
    //     "programme": {
    //        "RSDY1": [1,3,5]
    //      },
    //     "lecturer": {
    //        "Khor": [1,3,5]
    //      },
    //   },
    // }

    for (int i = 0; i < genesLength; i++) {
      ClassSession currentSession = classSessions[i];
      for (int x = 0; x < genes[i].occupiedSlot.length; x++) {
        int timeSlot = genes[i].occupiedSlot[x];
        if (!geneSlot.containsKey(timeSlot)) {
          geneSlot.putIfAbsent(
            timeSlot,
            () => {
              "venue": {
                currentSession.venue.id: [i]
              },
              "programme": {
                currentSession.course.courseCode.id: [i]
              },
              "lecturer": {
                currentSession.course.lecturer.id!: [i]
              }
            },
          );
        } else {
          // Venue
          List<int> venues = geneSlot[timeSlot]!["venue"]!
              .putIfAbsent(currentSession.venue.id, () => [i]);
          if (!venues.contains(i)) {
            venues.add(i);
          }
          // Programme
          List<int> programmes = geneSlot[timeSlot]!["programme"]!
              .putIfAbsent(currentSession.course.courseCode.id, () => [i]);
          if (!programmes.contains(i)) {
            programmes.add(i);
          }
          // Lecturer
          List<int> lecturers = geneSlot[timeSlot]!["venue"]!
              .putIfAbsent(currentSession.course.lecturer.id!, () => [i]);
          if (!lecturers.contains(i)) {
            lecturers.add(i);
          }
        }
      }
    }

    // For each time slot
    geneSlot.forEach((timeslot, value) {
      value.forEach((criteria, criteriaMap) {
        criteriaMap.forEach((id, geneIndexes) {
          if (geneIndexes.length > 1) {
            for (int i = 0; i < geneIndexes.length; i++) {
              genes[geneIndexes[i]].hasClash = true;
            }
          }
        });
      });
    });

    // for (int i = 0; i < slotLength; i++) {
    //   for (int x = 0; x < genesLength; x++) {
    //     for (int y = x + 1; y < genesLength; y++) {
    //       if (genes[x].slot[i]! && genes[y].slot[i]!) {
    //         if (classSessions[x].course.lecturer.id ==
    //                 classSessions[y].course.lecturer.id ||
    //             classSessions[x].course.courseCode ==
    //                 classSessions[y].course.courseCode ||
    //             classSessions[x].venue.venueID ==
    //                 classSessions[y].venue.venueID) {
    //           genes[x].hasClash = true;
    //           genes[y].hasClash = true;
    //         }
    //       }
    //     }
    //   }
    // }

    int numOfClashGene = 0;
    for (int i = 0; i < genesLength; i++) {
      if (genes[i].hasClash) {
        numOfClashGene++;
      }
    }

    // Fitness function = 1 / (1+(number of clash gene))
    fitness = 1 / (1 + numOfClashGene);
  }
}
