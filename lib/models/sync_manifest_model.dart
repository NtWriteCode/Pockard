class SyncManifest {
  final DateTime preferencesLastModified;
  final Map<String, DateTime> cardTimestamps;

  SyncManifest({required this.preferencesLastModified, required this.cardTimestamps});

  Map<String, dynamic> toJson() {
    return {'preferences_last_modified': preferencesLastModified.toIso8601String(), 'card_timestamps': cardTimestamps.map((key, value) => MapEntry(key, value.toIso8601String()))};
  }

  factory SyncManifest.fromJson(Map<String, dynamic> json) {
    return SyncManifest(
      preferencesLastModified: DateTime.parse(json['preferences_last_modified'] as String),
      cardTimestamps: (json['card_timestamps'] as Map<String, dynamic>).map((key, value) => MapEntry(key, DateTime.parse(value as String))),
    );
  }
}
