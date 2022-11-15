import 'dart:isolate';

class OptimizeIsolateModel {
  int maxGeneration;
  int toleratedConflicts;

  OptimizeIsolateModel({
    this.maxGeneration = 5000,
    this.toleratedConflicts = 5,
  });
}
