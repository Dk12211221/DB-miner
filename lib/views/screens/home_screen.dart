import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/json_controller.dart';
import '../../helpers/database_helper.dart';
import '../../models/quote_model.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<QuoteModel>>? allQuotes;

  final TextEditingController quoteController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    await loadQuotesFromJson();
    setState(() {
      allQuotes = DbHelper.dbHelper.fetchAllQuotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF1E1E2C) : const Color(0xFFE0F7FA);
    final cardColor = isDark ? const Color(0xFF2C2C3E) : const Color(0xFFCCE5FF);
    final textColor = isDark ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFF00C9FF);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
          ).createShader(bounds),
          child: Text(
            'QuoteVerse',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/fav'),
            icon: Icon(Icons.favorite_border, color: textColor),
          ),
          IconButton(
            onPressed: () {
              Get.changeTheme(Get.isDarkMode ? ThemeData.light() : ThemeData.dark());
            },
            icon: Icon(Get.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: textColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: cardColor,
                title: Text("Add New Quote", style: GoogleFonts.poppins()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: quoteController,
                      decoration: const InputDecoration(labelText: "Quote"),
                    ),
                    TextField(
                      controller: authorController,
                      decoration: const InputDecoration(labelText: "Author"),
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: "Category"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      final newQuote = QuoteModel(
                        quote: quoteController.text.trim(),
                        author: authorController.text.trim(),
                        category: categoryController.text.trim(),
                      );
                      await DbHelper.dbHelper.insertQuote(newQuote);
                      quoteController.clear();
                      authorController.clear();
                      categoryController.clear();
                      loadData();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Quote Added!")),
                      );
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            TextField(
              onChanged: (val) {
                setState(() {
                  allQuotes = DbHelper.dbHelper.searchQuotes(category: val);
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: cardColor.withOpacity(0.6),
                hintText: 'Search quotes by category...',
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<QuoteModel>>(
                future: allQuotes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final quote = snapshot.data![index];
                        return Card(
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            onTap: () async {
                              final result = await Get.to(() => QuoteDetailScreen(quote: quote));
                              if (result == true) {
                                setState(() {
                                  allQuotes = DbHelper.dbHelper.fetchAllQuotes();
                                });
                              }
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            title: Text(
                              quote.quote,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            subtitle: Text(
                              "- ${quote.author}",
                              style: GoogleFonts.poppins(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C9FF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                quote.category,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No quotes found"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
