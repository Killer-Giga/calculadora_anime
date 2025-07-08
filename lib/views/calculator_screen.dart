import 'package:calculadora_fea_a_5_pesos/widgets/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:calculadora_fea_a_5_pesos/widgets/calc_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _displayText = "";
  String state = "assets/images/start";
  int frameCount = 1;
  // metodo para cambiar el state del texto desde los botones en calc_button.dart
  void _onButtonPressed(String value, String input) {
    setState(() {
      _displayText = value;
      if (input == "=" || input == "%") {
        state = "assets/images/value";
        frameCount = 1;
      } else if (input == "C") {
        state = "assets/images/start";
        frameCount = 1;
      } else if (input == "error") {
        state = "assets/images/error";
        frameCount = 4;
      } else {
        state = "assets/images/calculated";
        frameCount = 4;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Calculadora")),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned(
            top: -200,
            bottom: 470,
            right: -100,
            child: AnimatedBackground(
              folderPath: state,
              frameCount: frameCount,
            ),
          ),

          // Contenido principal (encima del fondo)
          SafeArea(
            child: Column(
              // Resultado
              children: [
                Spacer(),
                Container(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      // Aqui esta la expresion y resultado.
                      _displayText,
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                ),

                // Botones
                SizedBox(
                  width: 500,
                  height: 370,
                  child: Container(
                    color: Colors.transparent,
                    child: CalcButton(onPressed: _onButtonPressed),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
