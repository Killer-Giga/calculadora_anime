import 'package:flutter/material.dart';
import 'package:calculadora_anime/widgets/calc_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool _imagesPrecached = false;
  String _displayText = "";
  String _image = "assets/images/mona_china_mejorada.png";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _precacheImages();
      _imagesPrecached = true;
    }
  }

  void _precacheImages() async {
    await precacheImage(const AssetImage("assets/images/mona_china_mejorada.png"), context);
    await precacheImage(
      const AssetImage("assets/images/mona_china_respuesta_hd.png"),
      context,
    );
    await precacheImage(
      const AssetImage("assets/images/mona_china_escribiendo_hd.png"),
      context,
    );
    await precacheImage(
      const AssetImage("assets/images/mona_china_error_hd.png"),
      context,
    );
  }

  // metodo para cambiar el estado del texto desde los botones en calc_button.dart
  void _onButtonPressed(String value, String input) {
    setState(() {
      _displayText = value;
      if (input == "=" || input == "%") {
        _image = "assets/images/mona_china_respuesta_hd.png";
      } else if (input == "C") {
        _image = "assets/images/mona_china_mejorada.png";
      } else if (input == "error") {
        _image = "assets/images/mona_china_error_hd.png";
        } else {
        _image = "assets/images/mona_china_escribiendo_hd.png";
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
          Positioned.fill(child: Image.asset(_image, fit: BoxFit.cover)),

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
