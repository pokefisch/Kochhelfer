import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kochhelfer_ui/pages/addRecipes.dart';
import 'package:kochhelfer_ui/pages/drawerfunctions.dart';

class HomePage extends StatefulWidget {
  
  
   HomePage({
    super.key,
  });
    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'vegetarische Gerichte',
      'icon': 'assets/icons/carrot.svg',
      'color': const Color.fromARGB(255, 80, 146, 17),
    },
    {
      'name': 'Hauptgerichte',
      'icon': 'assets/icons/main_course.svg',
      'color': const Color.fromARGB(255, 27, 121, 184),
    },
    {
      'name': 'Desserts',
      'icon': 'assets/icons/dessert.svg',
      'color': const Color.fromARGB(255, 27, 121, 184),
    },
    {
      'name': 'Getränke',
      'icon': 'assets/icons/drinks.svg',
      'color': const Color.fromARGB(255, 27, 121, 184),
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kochhelfer',  
        style: TextStyle(
          color: const Color.fromARGB(255, 27, 121, 184),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(75, 87, 87, 87),
      elevation: 0,
      leading: const CustomMenuButton(

      ),
    ),
    drawer: MainDrawer(
    ),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        const Text(
          'Willkommen zum Kochhelfer!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 27, 121, 184),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: const Text(
            'Finde Rezepte, erstelle Einkaufslisten und mehr.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(height: 20),
        GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                Navigator.pushReplacement(context)
              },
            )
          },
        ),
      ],
    ),
    
     );
  }
}
