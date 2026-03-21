import 'package:flutter/material.dart';

// 1. You need this to actually start the app!
void main() {
  runApp(const MyApp());
}

// 2. The App Shell (Only handles theme and routing setup)
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Kochhelfer',
      home: HomePage(), // We moved the Scaffold out to a new widget
    );
  }
}

// 3. The First Screen
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
  String url = "test"; 

  void _showAddRecipeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Neues Rezept'),
          content: TextField(
            controller: _urlController, // We attach our controller here!
            decoration: const InputDecoration(
              hintText: "https://www.rewe.de/rezepte/...",
              labelText: "Rezept-Link einfügen",
              border: OutlineInputBorder(), // Gives it a nice box outline
            ),
            keyboardType: TextInputType.url, // Optimizes the mobile keyboard for URLs
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                _urlController.clear(); // Clear the text
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Abbrechen'),
            ),
            // Submit Button
            ElevatedButton(
              onPressed: () {
                // 3. Grab the typed URL
                String enteredUrl = _urlController.text;
                
                // Close the dialog first
                Navigator.pop(context);
                
                // Clear the text field for next time
                _urlController.clear();

                // 4. NOW we navigate to the Recipe Page!
                if (enteredUrl.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddRecipePage(),
                    ),
                  );
                }
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Now, this 'context' is safely inside the MaterialApp!
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kochhelfer'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text('Menü'),
            ),
            ListTile(
              title: const Text('Rezept hinzufügen'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddRecipePage(), // Renamed to RecipePage
                  ),
                );
              },
            ),
          ],
        
        ),
      ),
      body: Container(
        color: Colors.green,
        child: const Center(
          child: Text('Hello World'),
        ),
      ),
      // Scaffold has a dedicated property for FloatingActionButtons!
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRecipeDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 4. The Second Screen (Capitalized class name)
class AddRecipePage extends StatelessWidget {
  const AddRecipePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezept'),
      ),
      body: const Center(
        child: Text('Rezeptinhalt'),
      ),
    );
  }
}