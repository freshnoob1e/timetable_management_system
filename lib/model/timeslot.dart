class TimeSlot {
  final int id;
  final DateTime startTime;
  final DateTime endTime;

  TimeSlot(this.id, this.startTime, this.endTime);

  bool isConflict(TimeSlot ts) {
    // Make only variable is hour and minute
    DateTime tempDT = DateTime.now();
    DateTime compareSelfStartTime =
        DateTime(tempDT.year, 1, 1, startTime.hour, startTime.minute);
    DateTime compareSelfEndTime =
        DateTime(tempDT.year, 1, 1, endTime.hour, endTime.minute);
    DateTime compareTargetStartTime =
        DateTime(tempDT.year, 1, 1, ts.startTime.hour, ts.startTime.minute);
    DateTime compareTargetEndTime =
        DateTime(tempDT.year, 1, 1, ts.endTime.hour, ts.endTime.minute);

    if ((compareSelfStartTime.compareTo(compareTargetEndTime) < 0) &&
        (compareSelfEndTime.compareTo(compareTargetStartTime) > 0)) {
      // print("$compareSelfStartTime - $compareSelfEndTime");
      // print("$compareTargetStartTime - $compareTargetEndTime\n\n");
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return "<TimeSlot: StartTime: $startTime, EndTime: $endTime>";
  }
}
