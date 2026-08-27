/// A person's membership in the current stable.
class Member {
  const Member({
    required this.name,
    required this.initial,
    required this.meta,
    required this.role,
  });
  final String name;
  final String initial;
  final String meta;
  final String role;
}

/// A stable the current account belongs to (role is per stable).
class StableMembership {
  const StableMembership({
    required this.name,
    required this.role,
    required this.meta,
  });
  final String name;
  final String role;
  final String meta;
}

/// Something waiting on the admin's approval.
class ApprovalRequest {
  const ApprovalRequest({
    required this.id,
    required this.kind,
    required this.title,
    required this.meta,
  });
  final String id;
  final String kind;
  final String title;
  final String meta;
}

/// Sample people/roles content for the foundation (server data in production).
abstract final class PeopleData {
  static const roles = ['Admin', 'Manager', 'Trainer', 'Groom', 'Owner', 'Rider'];

  static const members = <Member>[
    Member(name: 'Ahmad', initial: 'A', meta: 'You · Joy, Comme Ci and Abby', role: 'Admin'),
    Member(name: 'Layal', initial: 'L', meta: 'Runs the stable with you · rides Ghazal', role: 'Admin'),
    Member(name: 'Toni', initial: 'T', meta: 'Four horses assigned', role: 'Trainer'),
    Member(name: 'Rasil', initial: 'R', meta: 'Feeds and turnout', role: 'Groom'),
    Member(name: 'Jagdib', initial: 'J', meta: 'Evenings and weekends', role: 'Groom'),
  ];

  static const stables = <StableMembership>[
    StableMembership(name: 'Serc', role: 'Admin', meta: 'Dubai · 14 horses · you run it'),
    StableMembership(name: 'Al Marmoom Equestrian', role: 'Trainer', meta: 'Dubai · you log training here'),
    StableMembership(name: 'Desert Rose Stables', role: 'Rider', meta: 'Sharjah · one horse, Nour'),
  ];

  static const requests = <ApprovalRequest>[
    ApprovalRequest(id: 'r1', kind: 'Horse waiting', title: 'Layal wants to add Ghazal', meta: 'Arabian mare · 9 years · rider since March'),
    ApprovalRequest(id: 'r2', kind: 'Invite accepted', title: 'Toni accepted trainer', meta: 'Joins with trainer rights once approved'),
    ApprovalRequest(id: 'r3', kind: 'Role change', title: 'Jagdib asked to be trainer as well', meta: 'Currently groom at Serc'),
  ];

  /// Manager permissions the admin can toggle.
  static const managerPerms = <String>[
    'Approve horses and new people',
    'Send invites (not admin invites)',
    'Post and pin on the noticeboard',
    'Assign horses to trainers and riders',
    'See billing and contracts',
  ];
}
