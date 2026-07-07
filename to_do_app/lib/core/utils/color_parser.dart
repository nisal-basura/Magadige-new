import 'package:flutter/material.dart';

/// The backend stores category/dream colors as an unconstrained free-form
/// string (usually `#RRGGBB`, but not validated as such server-side) — parse
/// defensively and fall back rather than crash on an unexpected value.
Color colorFromHex(String? value, {Color fallback = const Color(0xFFA89A85)}) {
  if (value == null || value.isEmpty) return fallback;
  var hex = value.trim().replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return fallback;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

/// Inverse of [colorFromHex] — used when sending a user-picked color back to
/// the API's free-form `color` string field.
String colorToHex(Color color) {
  final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
  return '#${argb.substring(2)}';
}
