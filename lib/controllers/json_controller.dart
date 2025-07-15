import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../helpers/database_helper.dart';
import '../models/quote_model.dart';

Future<void> loadQuotesFromJson() async {
  try {
    // Avoid re-inserting if data already exists
    final existingQuotes = await DbHelper.dbHelper.fetchAllQuotes();
    if (existingQuotes.isNotEmpty) {
      print("ℹ️ Quotes already exist in the database.");
      return;
    }

    // Load JSON from assets
    final String jsonString = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);

    // Validate and parse
    final List<QuoteModel> quotes = jsonList
        .where((e) =>
    e is Map<String, dynamic> &&
        e.containsKey('quote') &&
        e.containsKey('author') &&
        e.containsKey('category'))
        .map((e) => QuoteModel(
      quote: e['quote']?.toString() ?? '',
      author: e['author']?.toString() ?? 'Unknown',
      category: e['category']?.toString() ?? 'General',
    ))
        .toList();

    // Insert into database
    for (final quote in quotes) {
      await DbHelper.dbHelper.insertQuote(quote);
    }

    print("✅ Loaded ${quotes.length} quotes from JSON into SQLite.");
  } catch (e) {
    print("❌ Error loading quotes from JSON: $e");
  }
}
