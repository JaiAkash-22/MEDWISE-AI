/// Represents a single scanned/saved medicine entry.
class Medicine {
  final String id;
  final String name;
  final String rawOcrText;
  final String explanation;
  final DateTime scannedAt;
  final String profileId; // which family member this belongs to

  Medicine({
    required this.id,
    required this.name,
    required this.rawOcrText,
    required this.explanation,
    required this.scannedAt,
    required this.profileId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rawOcrText': rawOcrText,
        'explanation': explanation,
        'scannedAt': scannedAt.toIso8601String(),
        'profileId': profileId,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json['id'],
        name: json['name'],
        rawOcrText: json['rawOcrText'],
        explanation: json['explanation'],
        scannedAt: DateTime.parse(json['scannedAt']),
        profileId: json['profileId'],
      );
}
