/// Lab 2 Individual Assignment (A2) -- CLI Mood Logger
///
/// Run with: dart run mood_logger.dart

import 'dart:io';

// ============================================================================
// MoodEntry Class
// ============================================================================

/// Represents a single mood log entry.
class MoodEntry {
  final DateTime createdAt;
  final int score;
  final String? note;

  MoodEntry(this.score, [this.note]) : createdAt = DateTime.now();

  /// Format: "[YYYY-MM-DD HH:MM] Score: <score>/10 - <note>"
  @override
  String toString() {
    String two(int n) => n.toString().padLeft(2, '0');
    final date = '${createdAt.year}-${two(createdAt.month)}-${two(createdAt.day)}';
    final time = '${two(createdAt.hour)}:${two(createdAt.minute)}';
    return '[$date $time] Score: $score/10 - ${note ?? '(no note)'}';
  }
}

// ============================================================================
// MoodLogger Class
// ============================================================================

/// Manages a collection of MoodEntry objects.
class MoodLogger {
  final List<MoodEntry> _entries = [];

  /// Adds a new mood entry. Score must be 1-10; blank notes become null.
  void addEntry(int score, String? note) {
    if (score < 1 || score > 10) {
      print('Error: score must be between 1 and 10.');
      return;
    }
    final trimmed = note?.trim();
    final cleanNote = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    _entries.add(MoodEntry(score, cleanNote));
    print('Entry added!');
  }

  /// Returns a copy of all entries.
  List<MoodEntry> getAllEntries() => List.from(_entries);

  /// Average score, or null when there are no entries.
  double? getAverageScore() {
    if (_entries.isEmpty) return null;
    final total = _entries.fold<int>(0, (sum, e) => sum + e.score);
    return total / _entries.length;
  }

  /// Entries with score >= [threshold].
  List<MoodEntry> getEntriesAbove(int threshold) =>
      _entries.where((e) => e.score >= threshold).toList();

  /// Total number of entries.
  int get entryCount => _entries.length;
}

// ============================================================================
// Main -- Interactive CLI
// ============================================================================

void main() {
  final logger = MoodLogger();

  print('=== Mood Logger ===');
  print('Track your daily mood on a scale of 1-10.\n');

  bool running = true;
  while (running) {
    print('1. Add mood entry');
    print('2. View all entries');
    print('3. View average mood');
    print('4. Filter by minimum score');
    print('5. Quit');
    stdout.write('\nChoose an option: ');

    String? input = stdin.readLineSync();
    if (input == null) {
      // EOF (e.g. Ctrl+D or piped input ended) -- exit cleanly.
      print('\nGoodbye!');
      break;
    }
    int? choice = int.tryParse(input.trim());

    switch (choice) {
      case 1:
        stdout.write('Enter mood score (1-10): ');
        final score = int.tryParse(stdin.readLineSync()?.trim() ?? '');
        if (score == null) {
          print('Error: please enter a whole number.');
          break;
        }
        stdout.write('Enter a note (or press Enter for none): ');
        final note = stdin.readLineSync();
        logger.addEntry(score, note);
        break;
      case 2:
        final entries = logger.getAllEntries();
        if (entries.isEmpty) {
          print('No entries yet.');
        } else {
          print('\n--- All entries (${logger.entryCount}) ---');
          for (final entry in entries) {
            print(entry);
          }
        }
        break;
      case 3:
        final avg = logger.getAverageScore();
        if (avg == null) {
          print('No entries yet. Add some entries first!');
        } else {
          print('Average mood score: ${avg.toStringAsFixed(1)} '
              '(based on ${logger.entryCount} entries)');
        }
        break;
      case 4:
        stdout.write('Enter minimum score (1-10): ');
        final threshold = int.tryParse(stdin.readLineSync()?.trim() ?? '');
        if (threshold == null) {
          print('Error: please enter a whole number.');
          break;
        }
        final filtered = logger.getEntriesAbove(threshold);
        if (filtered.isEmpty) {
          print('No entries with score >= $threshold.');
        } else {
          print('\n--- Entries with score >= $threshold ---');
          for (final entry in filtered) {
            print(entry);
          }
        }
        break;
      case 5:
        running = false;
        print('Goodbye!');
        break;
      default:
        print('Invalid option. Please choose 1-5.');
    }
    print('');
  }
}
