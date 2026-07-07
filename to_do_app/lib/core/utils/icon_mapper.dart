import 'package:flutter/material.dart';

/// Categories/badges come back from the API as free-form string identifiers
/// (e.g. "dollar-sign", "briefcase") with no server-side enum constraint.
/// This maps the known seeded values to Material icons, falling back to a
/// generic icon for anything unrecognized rather than throwing.
IconData iconForName(String? name) {
  switch (name) {
    case 'dollar-sign':
      return Icons.attach_money_rounded;
    case 'heart':
      return Icons.favorite_outline_rounded;
    case 'home':
      return Icons.home_outlined;
    case 'user':
      return Icons.person_outline_rounded;
    case 'book':
      return Icons.menu_book_outlined;
    case 'briefcase':
      return Icons.work_outline_rounded;
    case 'sunrise':
      return Icons.wb_twilight_outlined;
    case 'star':
      return Icons.star_border_rounded;
    case 'medal':
      return Icons.military_tech_outlined;
    case 'trophy':
      return Icons.emoji_events_outlined;
    case 'flame':
      return Icons.local_fire_department_outlined;
    default:
      return Icons.label_outline_rounded;
  }
}
