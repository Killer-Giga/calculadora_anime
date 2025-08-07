import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  String _expression = "";
  String _partialResult = "";
  String _result = "0";
  List<String> history = [];

  // Estado interno
  bool isPartialResult = false;
  bool afterResult = false;
  bool isError = false;

  final operators = ["+", "-", "x", "÷"];
  final advancedOperators = ["+", "-", "x", "÷", "%"];
  final numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

  String get expression => _expression;
  String get result => _result;
  String get partialResult => _partialResult;

  void addCharacter(String char) {
    // Manejo especial después de un resultado
    if (isError) {
      isError = false;
      _expression = "";
      _result = "";
    }

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
    evaluatePartial();
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
    _partialResult = "";
    afterResult = false;
    isPartialResult = false;
    isError = false;
  }

  void deleteLast() {
    if (_expression.isNotEmpty && !afterResult) {
      _expression = _expression.substring(0, _expression.length - 1);
      // Si la expresión queda vacía, restaurar valores
      if (_expression.isEmpty) {
        _result = "0";
        isPartialResult = false;
      }
      evaluatePartial();
    }
  }

  void toggleSign() {
    if (_expression.isEmpty) return;
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

  void percentage() {
    isPartialResult = false;

    if (afterResult) {
      double number = double.tryParse(_expression) ?? 0;
      double percentage = number / 100;
      _result = formatDouble(percentage);
      _expression = _result;
      _partialResult = _expression;
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

    //formattedExpression(rawResult);
    _result = formatDouble(rawResult);
    _expression = _result;
    _partialResult = _expression;
  }

  void evaluateExpression() {
    try {
      isPartialResult = false;
      final parsed = normalizedExpression();
      final value = evaluate(parsed);

      if (value == null) {
        _result = "No se puede dividir entre cero";
        afterResult = true;
        throw Exception("División por cero");
      }

      final formatted = formatDouble(value);
      history.add('$_expression = $formatted');
      _expression = formatted;
      _result = formatted;
      afterResult = true;
    } catch (e) {
      isError = true;
      if (_result != "No se puede dividir entre cero") {
        _result = "Error";
      }
      afterResult = true;
      rethrow;
    }
  }

  void evaluatePartial() {
    final parsed = normalizedExpression();
    final value = evaluate(parsed);

    if (value != null) {
      _partialResult = formatDouble(value);
      isPartialResult = true;
    } else {
      _partialResult = "";
      isPartialResult = false;
    }
  }

  double? evaluate(String expression) {
    try {
      final parser = GrammarParser().parse(expression);
      final context = ContextModel();
      final evaluator = RealEvaluator(context);
      final result = evaluator.evaluate(parser);

      if (result.isInfinite || result.isNaN) return null;

      return result.toDouble();
    } catch (e) {
      return null;
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

  String formatDouble(double rawResult) {
    if (rawResult.isInfinite || rawResult.abs() > 1e12) {
      return rawResult.toStringAsExponential(6);
    } else if (rawResult == rawResult.roundToDouble()) {
      return rawResult.toInt().toString();
    } else {
      return rawResult
          .toStringAsFixed(10)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }
}
