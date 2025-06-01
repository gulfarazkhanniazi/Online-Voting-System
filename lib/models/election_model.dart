class Election {
  String id;
  String title;
  DateTime startDate;
  DateTime endDate;
  Map<String, int> candidates; // string as name, int as vote count

  Election({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.candidates,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'candidates': candidates,
    };
  }

  factory Election.fromJson(Map<String, dynamic> json) {
    return Election(
      id: json['id'] as String,
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      candidates: Map<String, int>.from(
        json['candidates'].map(
          (key, value) => MapEntry(key as String, value as int),
        ),
      ),
    );
  }
}
