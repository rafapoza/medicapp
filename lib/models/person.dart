class Person {
  final String id;
  final String name;
  final bool isDefault; // Indica si es la persona por defecto (el usuario)

  Person({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDefault': isDefault ? 1 : 0, // Store as integer (SQLite doesn't have boolean)
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      name: json['name'] as String,
      isDefault: (json['isDefault'] as int?) == 1,
    );
  }

  /// Create a copy of the person with updated values
  Person copyWith({
    String? id,
    String? name,
    bool? isDefault,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person &&
        other.id == id &&
        other.name == name &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode => Object.hash(id, name, isDefault);

  @override
  String toString() => 'Person(id: $id, name: $name, isDefault: $isDefault)';
}
