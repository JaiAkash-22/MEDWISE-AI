/// Represents a scheduled reminder to take a medicine.
class Reminder {
  final String id;
  final String medicineName;
  final int hour; // 0-23
  final int minute; // 0-59
  final String profileId;

  Reminder({
    required this.id,
    required this.medicineName,
    required this.hour,
    required this.minute,
    required this.profileId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicineName': medicineName,
        'hour': hour,
        'minute': minute,
        'profileId': profileId,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'],
        medicineName: json['medicineName'],
        hour: json['hour'],
        minute: json['minute'],
        profileId: json['profileId'],
      );

  String get timeLabel {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}