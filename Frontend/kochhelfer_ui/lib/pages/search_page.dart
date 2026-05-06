import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:kochhelfer_ui/pages/drawerfunctions.dart';
import 'package:kochhelfer_ui/config.dart';
import 'package:kochhelfer_ui/models/RecipePreviewModel.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _queryController = TextEditingController();
  List<RecipePreviewModel> searchResults = [];
  List<String> categories = ['Alle']; // Default option
  String selectedCategory = 'Alle';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    final Uri apiUrl = Uri.parse('${ApiConfig.baseUrl}/categories');
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          categories = ['Alle', ...data.map((e) => e.toString())];
        });
      }
    } catch (e) {
      print('Network Error: $e');
    }
  }

  Future<void> performSearch() async {
    setState(() {
      isLoading = true;
    });

    final String query = _queryController.text;
    String urlStr = '${ApiConfig.baseUrl}/search_recipes?';
    
    if (query.isNotEmpty) {
      urlStr += 'query=${Uri.encodeComponent(query)}&';
    }
    if (selectedCategory != 'Alle') {
      urlStr += 'category=${Uri.encodeComponent(selectedCategory)}';
    }

    final Uri apiUrl = Uri.parse(urlStr);
    
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          searchResults = data.map((json) => RecipePreviewModel.fromJson(json)).toList();
        });
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rezept suchen',
          style: TextStyle(
            color: Color.fromARGB(255, 27, 121, 184),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(75, 87, 87, 87),
        elevation: 0,
        leading: const CustomMenuButton(),
      ),
      drawer: const MainDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _queryController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => performSearch(),
                decoration: InputDecoration(
                  hintText: 'Nach Rezepten suchen...',
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 27, 121, 184).withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 27, 121, 184)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Category Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text('Kategorie: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                          performSearch();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Search Button
            ElevatedButton(
              onPressed: performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 27, 121, 184),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Suchen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Results
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : searchResults.isEmpty
                      ? const Center(child: Text('Keine Ergebnisse gefunden.'))
                      : ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final recipe = searchResults[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: ListTile(
                                leading: recipe.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: recipe.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      )
                                    : const Icon(Icons.fastfood, size: 50),
                                title: Text(
                                  recipe.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Dauer: ${recipe.duration} Min | Portionen: ${recipe.portions}'),
                                onTap: () {
                                  // Can navigate to recipe detail page later
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
