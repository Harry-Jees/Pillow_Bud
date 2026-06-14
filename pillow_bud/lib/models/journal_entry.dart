class JournalEntry {
  final String id;
  final String text;
  final String mood; // emoji
  final DateTime dateCreated;
  final DateTime dateModified;

  JournalEntry({
    required this.id,
    required this.text,
    required this.mood,
    required this.dateCreated,
    required this.dateModified,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      text: json['text'] as String,
      mood: json['mood'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      dateModified: DateTime.parse(json['dateModified'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'mood': mood,
        'dateCreated': dateCreated.toIso8601String(),
        'dateModified': dateModified.toIso8601String(),
      };
}
