import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/motivation.dart';

class MotivationCard extends StatelessWidget {
  final MotivationMessage message;
  const MotivationCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: p.heroGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MOTIVATION',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(message.headline,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'SpaceGrotesk')),
          const SizedBox(height: 6),
          Text(message.body, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

class InspirationCard extends StatelessWidget {
  final Quote quote;
  const InspirationCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('"', style: TextStyle(fontSize: 42, height: 0.9, color: p.brand.withValues(alpha: 0.35), fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("TODAY'S INSPIRATION",
                    style: TextStyle(color: p.brandStrong, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6)),
                const SizedBox(height: 8),
                Text(quote.text,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'SpaceGrotesk', height: 1.3)),
                const SizedBox(height: 6),
                Text('— ${quote.author}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
