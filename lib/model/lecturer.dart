class Lecturer {
  int? id;
  String name;

  Lecturer(this.id, this.name);

  Lecturer.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }

  @override
  String toString() {
    return "Lecturer{id: $id, name: $name}";
  }
}
