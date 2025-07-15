import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../helpers/database_helper.dart';
import '../../models/quote_model.dart';

class QuoteDetailScreen extends StatelessWidget {
  final QuoteModel quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavorite = quote.isFavorite == 1;
    final backgroundColor = isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF2C2C3E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final chipColor = isDark ? Colors.teal.shade700 : Colors.blue.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            "Quote Details",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '"${quote.quote}"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "- ${quote.author}",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    children: [
                      Chip(
                        backgroundColor: chipColor,
                        label: Text(
                          quote.category,
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await DbHelper.dbHelper.deleteQuote(quote.id!);
                    Get.back(result: true);
                    Get.snackbar(
                      "Deleted",
                      "Quote has been deleted.",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.delete),
                  label: Text("Delete", style: GoogleFonts.poppins()),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFavorite ? Colors.orange : Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    int newValue = isFavorite ? 0 : 1;
                    await DbHelper.dbHelper.toggleFavorite(quote.id!, newValue);
                    Get.back(result: true);
                    Get.snackbar(
                      "Success",
                      isFavorite ? "Removed from Favorites" : "Added to Favorites",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  label: Text(
                    isFavorite ? "Unfavorite" : "Favorite",
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
