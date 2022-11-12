import 'package:timetable_management_system/utility/venue_type.dart';

class Venue {
  int id;
  String venueName;
  int? venueCapacity;
  VenueType venueType;

  Venue(this.id, this.venueName, this.venueCapacity, this.venueType);

  @override
  String toString() {
    return "<Venue: $venueName, $venueCapacity, $venueType>";
  }
}
