import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../helpers/database_helper.dart';
import '../../models/quote_model.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<QuoteModel>> _favQuotesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _favQuotesFuture = DbHelper.dbHelper.fetchFavorites();
  }

  void _removeFromFavorites(int quoteId) async {
    await DbHelper.dbHelper.toggleFavorite(quoteId, 0);
    Get.snackbar(
      "Removed",
      "Removed from Favorites",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    setState(() {
      _loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF2C2C3E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF00C9FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            "Favorite Quotes",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<QuoteModel>>(
        future: _favQuotesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<QuoteModel> favQuotes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: favQuotes.length,
              itemBuilder: (context, index) {
                QuoteModel quote = favQuotes[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${quote.quote}"',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "- ${quote.author}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              quote.category,
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: isDark
                                ? Colors.indigo.shade700
                                : Colors.indigo.shade100,
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.redAccent),
                            onPressed: () => _removeFromFavorites(quote.id!),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                "No favorites found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }
}
