import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  String _expression = "";
  String _result = "0";
  List<String> history = [];

  // Estado interno
  bool afterResult = false;

  final operators = ["+", "-", "x", "÷"];
  final advancedOperators = ["+", "-", "x", "÷", "%"];
  final numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

  String get expression => _expression;
  String get result => _result;

  void addCharacter(String char) {
    // Manejo especial después de un resultado
    if (_result.isNotEmpty &&
        _result != "0" &&
        _result != "Error" &&
        afterResult) {
      if (operators.contains(char)) {
        // Continuar desde el resultado con un operador
        _expression = _result + char;
        afterResult = false;
      } else if (char == ".") {
        // Nuevo número decimal después de resultado
        _expression = "0.";
        _result = "0";
        afterResult = false;
      } else {
        // Nuevo número después de resultado
        _expression = char;
        _result = "0";
        afterResult = false;
      }
      return;
    }

    // Manejo de punto decimal
    if (char == ".") {
      // Si no hay un número actual, agregar "0."
      if (_expression.isEmpty ||
          operators.any((op) => _expression.endsWith(op)) ||
          _expression.endsWith(" ")) {
        _expression += "0.";
      }
      // Verificar si ya hay un punto en el número actual
      else if (!hasDecimalPointInCurrentNumber()) {
        _expression += ".";
      }
      return;
    }

    // Manejo de operadores
    if (operators.contains(char)) {
      // Eliminar puntos decimales solitarios al final // Tal vez se pueda anexar a los operadores???
      if (_expression.endsWith(".")) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
      // Si el último carácter es un operador, reemplazarlo
      if (_expression.isNotEmpty &&
          operators.any((op) => _expression.endsWith(op))) {
        _expression = _expression.substring(0, _expression.length - 1) + char;
      } else {
        _expression += char;
      }
      return;
    }

    // No repetir 0
    if (startsWithInvalidZero()) {
      return;
    }
    // Manejo de números
    _expression += char;
  }

  bool hasDecimalPointInCurrentNumber() {
    // Busca hacia atrás hasta encontrar un operador o el inicio
    for (int i = _expression.length - 1; i >= 0; i--) {
      if (_expression[i] == '.') return true;
      if (operators.contains(_expression[i])) return false;
    }
    return false;
  }

  bool startsWithInvalidZero() {
    if (_expression.isEmpty) return false;

    int i = _expression.length - 1;

    // Retrocede hasta encontrar un operador o el inicio
    while (i >= 0 && !operators.contains(_expression[i])) {
      i--;
    }

    // Extrae el número actual
    String currentNumber = _expression.substring(i + 1);

    if (currentNumber == "0") {
      return true;
    }

    return false;
  }

  void clear() {
    _expression = "";
    _result = "0";
    afterResult = false;
  }

  void deleteLast() {
    if (_expression.isNotEmpty && !afterResult) {
      _expression = _expression.substring(0, _expression.length - 1);

      // Si la expresión queda vacía, restaurar valores
      if (_expression.isEmpty) {
        _result = "0";
      }
    }
  }

  void toggleSign() {
    if (afterResult) {
      afterResult = false;
    }

    // Buscar el último número en la expresión
    RegExp numberPattern = RegExp(r'([-+]?[0-9]*\.?[0-9]+)$');
    Match? match = numberPattern.firstMatch(_expression);

    if (match != null) {
      String numberStr = match.group(0)!;
      double number = double.tryParse(numberStr) ?? 0;

      // Cambiar el signo
      double newNumber = -number;
      String newNumberStr = newNumber.toString();

      // Mantener formato entero si es posible
      if (newNumber == newNumber.roundToDouble()) {
        newNumberStr = newNumber.toInt().toString();
      }

      // Se agrega + para que no se junten los numeros cuando se pasa negativo a positivo en una resta.
      if (newNumber >= 0) {
        newNumberStr = "+$newNumberStr";
      }

      // Reemplazar en la expresión
      _expression = _expression.replaceRange(
        match.start,
        match.end,
        newNumberStr,
      );
    }
  }

  String normalizedExpression() {
    if (_expression.isEmpty) return "0";
    // Eliminar operadores solitarios al final
    if (operators.any((op) => _expression.endsWith(op))) {
      _expression = _expression.substring(0, _expression.length - 1);
    }

    // Normalizar la expresión
    String normalizedExpr = _expression
        .replaceAll('x', '*')
        .replaceAll('÷', '/');

    // Eliminar puntos decimales solitarios al final
    if (normalizedExpr.endsWith(".")) {
      normalizedExpr = normalizedExpr.substring(0, normalizedExpr.length - 1);
    }
    return normalizedExpr;
  }

  void percentage() {
    if (afterResult) {
        double number = double.tryParse(_expression) ?? 0;
        double percentage = number / 100;
        formattedExpression(percentage);
    }

    String normalizedExpr = normalizedExpression();
    normalizedExpr += "%";

    // Regex que ahora acepta +, -, * y /
    final pattern = RegExp(r'^(.+?)([\+\-\*\/])([0-9]*\.?[0-9]+)%$');
    final match = pattern.firstMatch(normalizedExpr);
    if (match == null) return;

    final leftExpr = match.group(1)!; // ej. "200*50"
    final operator = match.group(2)!; // "+", "-", "*" o "/"
    final percentNum = double.parse(match.group(3)!); // ej. 50

    // Evalúo la parte previa
    final parser = GrammarParser();
    final expr = parser.parse(
      leftExpr.replaceAll('x', '*').replaceAll('÷', '/'),
    );
    final evaluator = RealEvaluator(ContextModel());
    final double a = evaluator.evaluate(expr).toDouble();

    // Aplico la regla de porcentaje según el operador
    double rawResult;
    switch (operator) {
      case '+':
        rawResult = a + (a * percentNum / 100);
        break;
      case '-':
        rawResult = a - (a * percentNum / 100);
        break;
      case '*':
        rawResult = a * (percentNum / 100);
        break;
      case '/':
        // cuidado con división por cero
        if (percentNum == 0) {
          _result = "No se puede dividir entre cero";
          return;
        }
        rawResult = a / (percentNum / 100);
        break;
      default:
        return;
    }

    formattedExpression(rawResult);
  }

  void evaluateExpression() {
    try {
      final parsed = normalizedExpression();
      final expr = GrammarParser().parse(parsed);
      final context = ContextModel();
      final evaluator = RealEvaluator(context);
      final value = evaluator.evaluate(expr);

      formattedExpression(value.toDouble());
    } catch (e) {
      _result = "Error";
    }
  }

  void formattedExpression(double rawResult) {
    String formatted;

    // 1) Si es infinito o demasiado grande, usamos exponencial
    if (rawResult.isInfinite || rawResult.abs() > 1e12) {
      formatted = rawResult.toStringAsExponential(6);
    }
    // 2) Si cabe en entero o decimal normal, seguimos igual
    else if (rawResult == rawResult.roundToDouble()) {
      formatted = rawResult.toInt().toString();
    } else {
      formatted = rawResult
          .toStringAsFixed(10)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }

    history.add('$_expression = $formatted');
    _expression = formatted;
    _result = formatted;
    afterResult = true;
  }
}