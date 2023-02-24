import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<Marker> _markers = [];
  
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: null,
      builder: (context, snapshot) {
        return Placeholder();
      },
    );
    
  }
}
