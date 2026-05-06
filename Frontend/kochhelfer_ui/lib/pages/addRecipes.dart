
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kochhelfer_ui/models/RecipeModel.dart';
import 'dart:convert';
import 'package:kochhelfer_ui/pages/drawerfunctions.dart';
// TODO: Make sure to import your RecipeModel and RecipePage here later!

class AddRecipesPage extends StatefulWidget {
  const AddRecipesPage({super.key});

  @override
  State<AddRecipesPage> createState() => _AddRecipesPageState();
}

class _AddRecipesPageState extends State<AddRecipesPage> {
  CachedNetworkImage recipeImage = CachedNetworkImage(
    imageUrl: '',
    placeholder: (context, url) => const CircularProgressIndicator(),
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
  RecipeModel? fetchedRecipe; // This will hold the recipe data 
  final TextEditingController _urlController = TextEditingController();
  
  //add the loading state variable
  bool isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
  // fetch Data for the recipe from the backend using the provided URL
  Future<void> fetchData(String recipeUrl) async {
    // Turn on the loading spinner
    setState(() {
      isLoading = true;
    });

    final Uri apiUrl = Uri.parse('http://172.24.245.2:8000/send_url');
    
    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'url': recipeUrl,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          fetchedRecipe = RecipeModel.fromJson(responseData);
          recipeImage = CachedNetworkImage(
            imageUrl: fetchedRecipe!.imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            scale: 2,
          );
        });
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error: $e');
    } finally {
      // Turn off the loading spinner, no matter what happens!
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> saveRecipe() async {
    if (fetchedRecipe == null) return false; // No recipe to save!

    final Uri apiUrl = Uri.parse('http://172.24.245.2:8000/save_recipe');
    try {
      final response = await http.post(
        apiUrl,
        
      );
      
      if (response.statusCode == 200) {
        print('Rezept erfolgreich gespeichert!');
        return true; // Assuming the backend returns a success status
      } else {
        print('Server Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Network Error: $e');
      return false;
    }
  }
  void showFeedbackDialog(String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ), 
      ),
      backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'OK', 
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
      );
      ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rezept hinzufügen',  
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
      drawer: const MainDrawer(), // Make sure your Drawer is const!
      
      // 3. We tell the body to show a spinner if isLoading is true!
      body: isLoading 
          ? LoadingIndicator()
          : SafeArea(
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    urlSearchField(),
                    const SizedBox(height: 20),
                    Center(child: addRecipeButton()), // Wrapped in Center to prevent stretching
                    const SizedBox(height: 40),
                    
                    // The Results Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gefundenes Rezept:',
                            style: TextStyle(
                              color: Color.fromARGB(255, 27, 121, 184),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (fetchedRecipe == null) 
                            const Text('Noch kein Rezept gesucht.', style: TextStyle(color: Colors.grey))
                          else ...[
                            // Display the recipe image
                            Center(child: recipeImage),
                            const SizedBox(height: 20),
                            
                            // Display the recipe title
                            Text(
                              fetchedRecipe!.title,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 27, 121, 184),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // Display preparation time and servings
                            Text(
                              'Zubereitungszeit: ${fetchedRecipe!.prepTimeMinutes} Minuten | Portionen: ${fetchedRecipe!.servings}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Display ingredients
                            const Text(
                              'Zutaten:',
                              style: TextStyle(
                                color: Color.fromARGB(255, 27, 121, 184),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // List of ingredients
                            ...fetchedRecipe!.ingredients.map((ingredient) => Text(
                              '- ${ingredient.amount} ${ingredient.unit} ${ingredient.name}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            )),
                            const SizedBox(height: 20),
                            //Save recipe button
                            Center(child: saveRecipeButton()),
                            const SizedBox(height: 40),
                          ],
              
                        ],
                      ),
                    )
                  ],
                ),
            ),
          ),
    );
  }

  Center LoadingIndicator() {
    return const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 27, 121, 184),
            ),
          );
  }
  Container saveRecipeButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () async {
          String url = _urlController.text;
          if (url.trim().isNotEmpty) {
            bool response = await saveRecipe(); // This now safely triggers the spinner!
            if (response) {
              showFeedbackDialog('Rezept erfolgreich gespeichert!', true);
            } else {
              showFeedbackDialog('Fehler beim Speichern des Rezepts.', false);
            }
          }
          
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 199, 58, 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        child: const Text(
          'Rezept speichern',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Container addRecipeButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          String url = _urlController.text;
          if (url.trim().isNotEmpty) {
            fetchData(url); // This now safely triggers the spinner!
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 27, 121, 184),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        child: const Text(
          'Rezept hinzufügen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Container urlSearchField() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration( 
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.1),
            spreadRadius: 0.0,
            blurRadius: 40,
            offset: const Offset(0, 3), 
          ),
        ],
      ),
      child: TextField(
        textInputAction: TextInputAction.search,
        controller: _urlController,
        onSubmitted: (String text) {
          if (text.trim().isNotEmpty) {
            fetchData(text); // 4. Now the mobile keyboard "Enter" button actually searches!
          }
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none, 
          ),
          hintText: 'URL zu Rezept eingeben',
          hintStyle: TextStyle( 
            color: const Color.fromARGB(255, 27, 121, 184).withValues(alpha: 0.5),
            fontSize: 18,
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 255, 255),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12), // Changed back to 12 for perfect centering
            child: SvgPicture.asset(
              'assets/icons/Search.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                const Color.fromARGB(255, 27, 121, 184).withValues(alpha: 0.5), 
                BlendMode.srcIn
              ),
            ),
          ),
        ),
      ),
    );
  }
}