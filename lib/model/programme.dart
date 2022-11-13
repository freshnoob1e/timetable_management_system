class Programme {
  int? id;
  String programmeCode;

  Programme(this.id, this.programmeCode);

  Map<String, dynamic> toMap() {
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
