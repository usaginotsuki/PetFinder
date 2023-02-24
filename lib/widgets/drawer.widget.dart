import 'package:flutter/material.dart';
import 'package:pet_finder/pages/homescreen.page.dart';
import 'package:pet_finder/pages/profile.page.dart';

@override
Widget drawerMenu(BuildContext context) {
  return Drawer(
    child: ListView(
      children: [
        DrawerHeader(child: Image.asset("assets/gastos.jpg")
            /*decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/gastos.jpg"),
                ),
                color: Colors.blue,*/
            ),
        ListTile(
          title: Text("Mapa"),
          trailing: Icon(Icons.map),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        ListTile(
          title: Text("Perfil"),
          trailing: Icon(Icons.person),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ],
    ),
  );
}
