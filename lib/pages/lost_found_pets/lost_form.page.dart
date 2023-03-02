import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pet_finder/widgets/drawer.widget.dart';

class LostForm extends StatefulWidget {
  const LostForm({super.key});

  @override
  State<LostForm> createState() => _LostFormState();
}

class _LostFormState extends State<LostForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerMenu(context),
      appBar: AppBar(
        title: const Text("Formulario de mascotas perdidas"),
        toolbarOpacity: 0.8,
      ),
      body: const Center(
        child: Text("Formulario de mascotas perdidas"),
      ),
    );
  }
}
