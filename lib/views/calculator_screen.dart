import 'package:flutter/material.dart';
import 'package:calculadora_anime/widgets/calc_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool _imagesPrecached = false;
  bool _showPartialResult = false;
  String _displayText = "";
  String _partialResult = "";
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
    await precacheImage(
      const AssetImage("assets/images/mona_china_mejorada.png"),
      context,
    );
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
  void _onButtonPressed(
    String value,
    String input,
    bool isPartialResult,
    String partialResult,
  ) {
    setState(() {
      _displayText = value;
      _showPartialResult = isPartialResult;
      _partialResult = partialResult;
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
          Positioned.fill(
            child: Image.asset(
              _image,
              fit: BoxFit.cover,
              gaplessPlayback:
                  true, // <- Esto evita el parpadeo entre cambios de imagen
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
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 175),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        reverse: true,
                        child: Text(
                          // Aqui esta la expresion y resultado.
                          _displayText,
                          style: TextStyle(fontSize: 32, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

                if (_showPartialResult)
                  Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.only(
                      bottom: 2,
                      left: 4,
                      right: 4,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _partialResult, // <- Aquí puedes usar una nueva variable de estado
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color.fromARGB(222, 255, 255, 255),
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
