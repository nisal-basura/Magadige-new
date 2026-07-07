import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role;
  final String plan;
  final String? headline;
  final String timezone;
  final String themePreference;
  final int streakCurrent;
  final int streakLongest;
  final int productivityScore;
  final bool isActive;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role = 'user',
    this.plan = 'Free',
    this.headline,
    this.timezone = 'UTC',
    this.themePreference = 'auto',
    this.streakCurrent = 0,
    this.streakLongest = 0,
    this.productivityScore = 0,
    this.isActive = true,
    this.emailVerifiedAt,
    required this.createdAt,
  });

  /// Two-letter initials for the avatar placeholder — the API has no such
  /// field, so it's derived from the name the same way the mock used to.
  String get avatarInitials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2);
    final initials = parts.map((p) => p[0].toUpperCase()).join();
    return initials.isEmpty ? 'U' : initials;
  }

  String get memberSince => DateFormat('MMMM y').format(createdAt);

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? headline,
    int? streakCurrent,
    int? streakLongest,
    int? productivityScore,
    String? plan,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      plan: plan ?? this.plan,
      headline: headline ?? this.headline,
      timezone: timezone,
      themePreference: themePreference,
      streakCurrent: streakCurrent ?? this.streakCurrent,
      streakLongest: streakLongest ?? this.streakLongest,
      productivityScore: productivityScore ?? this.productivityScore,
      isActive: isActive,
      emailVerifiedAt: emailVerifiedAt,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatar_url'] as String?,
        role: json['role'] as String? ?? 'user',
        plan: json['plan'] as String? ?? 'Free',
        headline: json['headline'] as String?,
        timezone: json['timezone'] as String? ?? 'UTC',
        themePreference: json['theme_preference'] as String? ?? 'auto',
        streakCurrent: json['streak_current'] as int? ?? 0,
        streakLongest: json['streak_longest'] as int? ?? 0,
        productivityScore: json['productivity_score'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        emailVerifiedAt:
            json['email_verified_at'] != null ? DateTime.tryParse(json['email_verified_at'] as String) : null,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
        'role': role,
        'plan': plan,
        'headline': headline,
        'timezone': timezone,
        'theme_preference': themePreference,
        'streak_current': streakCurrent,
        'streak_longest': streakLongest,
        'productivity_score': productivityScore,
        'is_active': isActive,
        'email_verified_at': emailVerifiedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        role,
        plan,
        headline,
        timezone,
        themePreference,
        streakCurrent,
        streakLongest,
        productivityScore,
        isActive,
        emailVerifiedAt,
        createdAt,
      ];
}
