import 'package:flutter/material.dart';
import 'package:practica_04_detalle_pelicula/src/screens/detail_screen.dart';
import 'package:practica_04_detalle_pelicula/src/screens/favorites_screen.dart';
import 'package:practica_04_detalle_pelicula/src/screens/popular_screen.dart';
import 'package:practica_04_detalle_pelicula/src/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/movies': (BuildContext context) => PopularScreen(),
        '/detail': (BuildContext context) => DetailScreen(),
        '/listFavorites': (BuildContext context) => FavoriteScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Acme'
      ),
      home: SplashScreen(),
    );
  }
}