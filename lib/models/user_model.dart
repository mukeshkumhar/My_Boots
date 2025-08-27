// lib/features/auth/user_model.dart
class AppUser {
  final String id;
  final String username;
  final String email;
  final int contact;
  final bool admin;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.contact,
    required this.admin,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      contact:
          json['contact'] is int
              ? json['contact'] as int
              : int.tryParse(json['contact']?.toString() ?? '0') ?? 0,
      admin:
          (json['admin'] is bool)
              ? json['admin'] as bool
              : (json['admin']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'contact': contact,
    'admin': admin,
  };
}
