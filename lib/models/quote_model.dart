class QuoteModel {
  final int? id;
  final String quote;
  final String author;
  final String category;
  final int isFavorite;

  QuoteModel({
    this.id,
    required this.quote,
    required this.author,
    required this.category,
    this.isFavorite = 0,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'],
      quote: json['quote'],
      author: json['author'],
      category: json['category'],
      isFavorite: json['isFavorite'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quote': quote,
      'author': author,
      'category': category,
      'isFavorite': isFavorite,
    };
  }

  @override
  String toString() {
    return 'QuoteModel(id: $id, quote: "$quote", author: "$author", category: "$category", isFavorite: $isFavorite)';
  }
}
