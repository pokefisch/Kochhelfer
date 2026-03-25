import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kochhelfer_ui/pages/addRecipes.dart';
import 'package:kochhelfer_ui/pages/drawerfunctions.dart';

class HomePage extends StatefulWidget {
  
  const HomePage({
    super.key,
  });
    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    );
  }
}
