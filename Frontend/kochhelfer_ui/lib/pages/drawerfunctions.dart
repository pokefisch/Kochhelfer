import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kochhelfer_ui/pages/addRecipes.dart';
import 'package:kochhelfer_ui/pages/home.dart';
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      child: ListView(
        padding: EdgeInsets.zero, // Cleaner way to write EdgeInsets.all(0)
        // Make sure there is NO 'const' before this children list!
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            child: Text(
              'Menü',
              style: TextStyle(
                color: Color.fromARGB(255, 27, 121, 184),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 1. Home
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          
          // 2. Search (Fixed with dimensions and a title!)
          ListTile(
            // No 'const' here!
            leading: SvgPicture.asset(
              'assets/icons/Search.svg',
              width: 24, // Matches standard Material Icon size
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn), // Ensures it matches your theme
            ),
            title: const Text('Suche'), // Added a title so it's not blank!
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddRecipesPage()),
              );
              // Handle Search tap
            },
          ),
          
          // 3. Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// Your Custom Reusable Menu Button!
class CustomMenuButton extends StatelessWidget {
  const CustomMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    // We keep the Builder here so it can safely find the Scaffold on any page
    return Builder(
      builder: (BuildContext innerContext) {
        return GestureDetector(
          onTap: () => Scaffold.of(innerContext).openDrawer(),
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              'assets/icons/menu-bars.svg',
              colorFilter: const ColorFilter.mode(Color.fromARGB(190, 0, 0, 0), BlendMode.srcIn),
              height: 20,
              width: 20,
            ),
          ),
        );
      },
    );
  }
}

