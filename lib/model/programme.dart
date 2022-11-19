class Programme {
  int? id;
  String programmeCode;

  Programme(this.id, this.programmeCode);

  Programme.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        programmeCode = json['programmeCode'];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "programmeCode": programmeCode,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "programmeCode": programmeCode,
    };
  }

  @override
  String toString() {
    return "Programme{id: $id, programmeCode: $programmeCode";
  }
}
