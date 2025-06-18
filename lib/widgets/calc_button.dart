import 'package:calculadora_anime/logic/calculator_logic.dart';
import 'package:flutter/material.dart';

class CalcButton extends StatefulWidget {

  final void Function(String, String) onPressed;

  const CalcButton({super.key, required this.onPressed});

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {

  final calculator = CalculatorLogic();
  double printNumber = 0;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
          crossAxisCount: 4, // Número de columnas
          childAspectRatio: 1.3, // Relación ancho/alto
          physics: const NeverScrollableScrollPhysics(), // evita scroll
          padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
          children: [
            for (var label in [
              '%','+-','C','÷',
              '7','8','9','x',
              '4','5','6','-',
              '1','2','3','+',
              '0','.','DEL','=',
            ])
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(
                      style: BorderStyle.solid,
                      color: Colors.white70,
                      width: 4
                    ),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white 
                  ),
                  onPressed: (){
                    switch(label){
                      case "DEL":
                        calculator.deleteLast();
                        widget.onPressed(calculator.expression, label);
                        break;
                      case "C":
                        calculator.clear();
                        widget.onPressed(calculator.result, label);
                        break;
                      case "=":
                        calculator.evaluateExpression();
                        widget.onPressed(calculator.result, label);
                        break;
                      case "+-":
                        calculator.toggleSign();
                        widget.onPressed(calculator.expression, label);
                        break;
                      case "%":
                        calculator.percentage();
                        widget.onPressed(calculator.result, label);
                        break;
                      default:
                        calculator.addCharacter(label);
                        widget.onPressed(calculator.expression, label);
                        break;
                    }
                  },
                  child: label == "DEL" ? Icon(Icons.backspace, size: 25) : 
                  label == "+-" ? Text("+/-", style: const TextStyle(fontSize: 20)) :
                  Text(label, style: const TextStyle(fontSize: 25)),
                ),
              ),
          ],
    );
  }
}
