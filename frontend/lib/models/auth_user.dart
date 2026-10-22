class AuthUser {
  const AuthUser({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'role': role,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'Fish Farmer',
    );
  }
}

String userInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'TS';
  if (parts.length == 1) {
    final first = parts.first;
    return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
