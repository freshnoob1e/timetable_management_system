import 'package:timetable_management_system/utility/venue_type.dart';

class Venue {
  int? id;
  String venueName;
  int? venueCapacity;
  VenueType venueType;

  Venue(this.id, this.venueName, this.venueCapacity, this.venueType);

  Venue.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        venueName = json['venueName'],
        venueCapacity = json['venueCapacity'],
        venueType = VenueType.values[json['venueType']];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "venueName": venueName,
      "venueCapacity": venueCapacity,
      "venueType": venueType.index,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "venueName": venueName,
      "venueCapacity": venueCapacity,
      "venueType": venueType.index,
    };
  }

  @override
  String toString() {
    return "<Venue: $venueName, $venueCapacity, $venueType>";
  }
}
