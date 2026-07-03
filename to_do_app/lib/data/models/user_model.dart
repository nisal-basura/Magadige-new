import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String name;
  final String role;
  final String email;
  final String avatarInitials;
  final String memberSince;
  final String timezone;
  final int streakCurrent;
  final int streakLongest;
  final int productivityScore;
  final String plan;

  const UserModel({
    required this.name,
    required this.role,
    required this.email,
    required this.avatarInitials,
    required this.memberSince,
    required this.timezone,
    this.streakCurrent = 0,
    this.streakLongest = 0,
    this.productivityScore = 0,
    this.plan = 'Free Plan',
  });

  UserModel copyWith({
    String? name,
    String? role,
    String? email,
    String? avatarInitials,
    int? streakCurrent,
    int? streakLongest,
    int? productivityScore,
    String? plan,
  }) {
    return UserModel(
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      memberSince: memberSince,
      timezone: timezone,
      streakCurrent: streakCurrent ?? this.streakCurrent,
      streakLongest: streakLongest ?? this.streakLongest,
      productivityScore: productivityScore ?? this.productivityScore,
      plan: plan ?? this.plan,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String,
        role: json['role'] as String,
        email: json['email'] as String,
        avatarInitials: json['avatarInitials'] as String,
        memberSince: json['memberSince'] as String,
        timezone: json['timezone'] as String,
        streakCurrent: json['streakCurrent'] as int? ?? 0,
        streakLongest: json['streakLongest'] as int? ?? 0,
        productivityScore: json['productivityScore'] as int? ?? 0,
        plan: json['plan'] as String? ?? 'Free Plan',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'email': email,
        'avatarInitials': avatarInitials,
        'memberSince': memberSince,
        'timezone': timezone,
        'streakCurrent': streakCurrent,
        'streakLongest': streakLongest,
        'productivityScore': productivityScore,
        'plan': plan,
      };

  @override
  List<Object?> get props => [
        name,
        role,
        email,
        avatarInitials,
        memberSince,
        timezone,
        streakCurrent,
        streakLongest,
        productivityScore,
        plan,
      ];
}
