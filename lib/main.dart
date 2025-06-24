import 'package:flutter/material.dart';
import 'package:calculadora_anime/views/calculator_screen.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CalculatorScreen(), 
    debugShowCheckedModeBanner: false,);
  }
}
