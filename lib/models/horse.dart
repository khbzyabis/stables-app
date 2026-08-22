/// A horse's wellbeing at a glance. Sage "Well" means settled; terracotta
/// "Watch" means attention.
enum HorseStatus { well, watch }

/// A horse. Adding one is deliberately minimal — a name is all that is
/// required; everything else is optional and added later or never.
class Horse {
  Horse({
    required this.id,
    required this.name,
    this.statusLine = '',
    this.status = HorseStatus.well,
    this.addedToday = false,
    this.age,
    this.breed,
    this.sex,
    this.height,
    this.box,
    this.notes,
  });

  final String id;
  final String name;

  /// One-line status shown in the home list, e.g. "Farrier due Thursday".
  final String statusLine;
  final HorseStatus status;
  final bool addedToday;

  // Optional details.
  final String? age;
  final String? breed;
  final String? sex;
  final String? height;
  final String? box;
  final String? notes;

  bool get hasDetails =>
      [age, breed, sex, height, box, notes].any((v) => v != null && v.isNotEmpty);
}
