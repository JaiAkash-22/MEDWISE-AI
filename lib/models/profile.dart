/// Represents a family member profile (for the Family Profiles feature).
class Profile {
  final String id;
  final String name;
  final String? notes; // e.g. allergies, conditions — shown on Emergency QR

  Profile({required this.id, required this.name, this.notes});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'notes': notes,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'],
        name: json['name'],
        notes: json['notes'],
      );
}
