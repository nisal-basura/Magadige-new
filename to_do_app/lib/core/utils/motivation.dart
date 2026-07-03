import '../../data/datasources/seed_data.dart';
import '../theme/theme_state.dart';

class MotivationMessage {
  final String headline;
  final String body;
  const MotivationMessage(this.headline, this.body);
}

class Quote {
  final String text;
  final String author;
  const Quote(this.text, this.author);
}

/// Context-aware copy generator — mirrors js/quotes.js. Deliberately avoids
/// pure randomness: the message reflects what the user has actually done.
class Motivation {
  Motivation._();

  static MotivationMessage messageFor({required int completed, required int pending, required int overdue, required int total}) {
    if (total > 0 && completed == total) {
      return const MotivationMessage(
        'Outstanding work today.',
        'Consistency builds success. Every task closed today compounds tomorrow.',
      );
    }
    if (overdue > 0) {
      return MotivationMessage(
        '$overdue important ${overdue == 1 ? "task is" : "tasks are"} waiting for you.',
        "Let's finish it today — clearing overdue work frees up real mental space.",
      );
    }
    if (completed == 0 && pending > 0) {
      return const MotivationMessage(
        'Start with one small task.',
        'Momentum begins with a single step. Pick the easiest one and go.',
      );
    }
    if (completed > 0 && completed < total) {
      final pct = ((completed / total) * 100).round();
      return MotivationMessage('You\'re $pct% through today.', 'Good pace — keep the momentum rolling into the next task.');
    }
    return const MotivationMessage('A fresh page, a fresh start.', "Set today's focus and let's build something worth remembering.");
  }

  static Quote inspirationFor(AppDayPeriod period, {int? overdue, int? completed, int? total}) {
    final quotes = SeedData.quotes;
    final seed = DateTime.now().day + period.index + (overdue ?? 0) * 3;
    final index = seed % quotes.length;
    final q = quotes[index];
    return Quote(q['text']!, q['author']!);
  }
}
