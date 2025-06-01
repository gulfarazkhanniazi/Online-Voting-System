class Candidate {
  final String id;
  final String name;
  final String symbol;
  final String party;
  final String slogan;

  Candidate({
    required this.id,
    required this.name,
    required this.symbol,
    required this.party,
    required this.slogan,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      party: json['party'],
      slogan: json['slogan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'party': party,
      'slogan': slogan,
    };
  }
}
