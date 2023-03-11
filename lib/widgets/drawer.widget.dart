import 'package:flutter/material.dart';
import 'package:pet_finder/pages/homescreen.page.dart';
import 'package:pet_finder/pages/login.page.dart';
import 'package:pet_finder/pages/my_reports.page.dart';
import 'package:pet_finder/pages/nearby_reports.dart';
import 'package:pet_finder/pages/profile.page.dart';
import 'package:pet_finder/services/auth.services.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';

@override
Widget drawerMenu(BuildContext context) {
  SharedPrefs sharedPrefs = SharedPrefs();
  AuthServices authServices = AuthServices();
  var screenSize = MediaQuery.of(context).size;
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
          title: Text("Mis reportes"),
          trailing: Icon(Icons.info),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyReports()),
            );
          },
        ),
        ListTile(
          title: Text("Alertas cercanas"),
          trailing: Icon(Icons.network_wifi_sharp),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NearbyReports()),
            );
          },
        ),
        Padding(padding: EdgeInsets.only(top: screenSize.height * 0.40)),
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
        ListTile(
          title: Text("Cerrar Sesión"),
          trailing: Icon(Icons.logout),
          onTap: () {
            sharedPrefs.setUserID("");
            authServices.signOut();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ],
    ),
  );
}
