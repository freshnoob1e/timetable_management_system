import 'dart:math';

import 'package:timetable_management_system/genetic_algorithm/chromosome.dart';
import 'package:timetable_management_system/genetic_algorithm/gene.dart';
import 'package:timetable_management_system/genetic_algorithm/population.dart';
import 'package:timetable_management_system/model/class_session.dart';

class GeneticAlgorithm {
  Population population = Population();
  late Chromosome fittest;
  late Chromosome secondFittest;
  int generationCount = 0;

  void selection() {
    // Select fittest individual
    fittest = population.getFittest();
    // Deep copy
    // geneindex, [gene timeslots]
    List<Gene> newGenes = [];
    for (int x = 0; x < fittest.genesLength; x++) {
      List<int> occupiedSlot = [];
      for (int ts in fittest.genes[x].occupiedSlot) {
        occupiedSlot.add(ts);
      }
      newGenes.add(Gene(occupiedSlot));
    }
    Chromosome newChromosome = Chromosome(newGenes);
    fittest = newChromosome;

    fittest.calcFitness(population.classSessions);

    // Select second fittest individual
    secondFittest = population.getSecondFittest();
    // Deep copy
    // geneindex, [gene timeslots]
    newGenes = [];
    for (int x = 0; x < secondFittest.genesLength; x++) {
      List<int> occupiedSlot = [];
      for (int ts in secondFittest.genes[x].occupiedSlot) {
        occupiedSlot.add(ts);
      }
      newGenes.add(Gene(occupiedSlot));
    }
    newChromosome = Chromosome(newGenes);
    secondFittest = newChromosome;

    secondFittest.calcFitness(population.classSessions);
  }

  void crossover() {
    Random rn = Random();

    int crossoverPoint = rn.nextInt(population.classSessions.length);
    if (crossoverPoint == 0) crossoverPoint = 1;
    // Swap values among parents
    for (int i = 0; i < crossoverPoint; i++) {
      Gene temp = fittest.genes[i];
      fittest.genes[i] = secondFittest.genes[i];
      secondFittest.genes[i] = temp;
    }
  }

  void mutation() {
    Random rn = Random();

    // Select random mutation point
    int mutationPoint1 = rn.nextInt(population.classSessions.length);
    if (mutationPoint1 == 0) mutationPoint1 = 1;

    // Randomize value at mutation point
    Gene newGene = population.shiftRandomSlot(
        population.classSessions[mutationPoint1], population.timeslotLength);
    fittest.genes[mutationPoint1] = newGene;

    // Select random mutation point for second fittest
    mutationPoint1 = rn.nextInt(population.classSessions.length);
    if (mutationPoint1 == 0) mutationPoint1 = 1;

    // Randomize value at mutation point
    newGene = population.shiftRandomSlot(
        population.classSessions[mutationPoint1], population.timeslotLength);
    secondFittest.genes[mutationPoint1] = newGene;
  }

  // Get fittest offspring
  Chromosome getFittestOffspring() {
    if (fittest.fitness > secondFittest.fitness) {
      return fittest;
    }
    return secondFittest;
  }

  // Replace least fittest with fittest offspring
  void addFittestOffspring() {
    // Update offspring fitnest value
    fittest.calcFitness(population.classSessions);
    secondFittest.calcFitness(population.classSessions);

    // Get least fittest index
    int leastFitIndex = population.getLeastFitIndex();

    // Compare new gen and old gen
    Chromosome fittestOffspring = getFittestOffspring();
    double leastFitFitness = population.chromosomes[leastFitIndex].fitness;
    if (leastFitFitness < fittestOffspring.fitness) {
      // Replace
      // Deep copy
      // geneindex, [gene timeslots]
      List<Gene> newGenes = [];
      for (int x = 0; x < fittestOffspring.genesLength; x++) {
        List<int> occupiedSlot = [];
        for (int ts in fittestOffspring.genes[x].occupiedSlot) {
          occupiedSlot.add(ts);
        }
        newGenes.add(Gene(occupiedSlot));
      }
      Chromosome newChromosome = Chromosome(newGenes);
      population.chromosomes[leastFitIndex] = newChromosome;
    }
  }

  List<ClassSession> getChromosomeClassSessions(
    Chromosome chromosome,
    int startHourInt,
  ) {
    List<ClassSession> classSessions = [];

    for (int i = 0; i < chromosome.genesLength; i++) {
      List<int> occupiedSlot = chromosome.genes[i].occupiedSlot;
      int startSlot = occupiedSlot[0];
      int endSlot = occupiedSlot[occupiedSlot.length - 1];

      DateTime startTime = population.timeslots[startSlot].startTime;
      DateTime endTime = population.timeslots[endSlot].endTime;

      classSessions.add(
        ClassSession(
          0,
          population.classSessions[i].course,
          population.classSessions[i].classType,
          population.classSessions[i].venue,
          startTime,
          endTime,
        ),
      );
    }
    return classSessions;
  }
}
