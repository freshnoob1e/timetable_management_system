import 'package:intl/intl.dart';

class TimeSlot {
  final int? id;
  final DateTime startTime;
  final DateTime endTime;

  TimeSlot(this.id, this.startTime, this.endTime);

  Map<String, dynamic> toMap() {
    String startTimeStr = DateFormat("yyyy-MM-dd HH:mm:ss").format(startTime);
    String endTimeStr = DateFormat("yyyy-MM-dd HH:mm:ss").format(endTime);

    return {
      "id": id,
      "startTime": startTimeStr,
      "endTime": endTimeStr,
    };
  }

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
      return true;
    }
    return false;
  }

  bool isConflictFullDT(TimeSlot ts) {
    if ((startTime.compareTo(ts.endTime) < 0) &&
        (endTime.compareTo(ts.startTime) > 0)) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return "<TimeSlot: StartTime: $startTime, EndTime: $endTime>";
  }
}
