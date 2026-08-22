/// A task set by an admin/trainer for grooms to tick off. Carries who set it, a
/// due time, and optionally a note.
class StableTask {
  const StableTask({
    required this.id,
    required this.title,
    required this.meta,
    required this.time,
    this.note = '',
  });

  final String id;
  final String title;
  final String meta;
  final String time;
  final String note;

  bool get hasNote => note.isNotEmpty;
}

/// A staff member's task completion, for the admin's "who has done what" view.
class StaffProgress {
  const StaffProgress({
    required this.name,
    required this.initial,
    required this.role,
    required this.done,
    required this.total,
    required this.latest,
  });

  final String name;
  final String initial;
  final String role;
  final int done;
  final int total;
  final String latest;

  bool get allDone => done >= total;
  double get fraction => total == 0 ? 0 : done / total;
}
