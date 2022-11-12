class Lecturer {
  int? id;
  String name;

  Lecturer(this.id, this.name);

  Map<String, dynamic> toMap() {
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
