class MeasurementConverter {
  static const Map<String, double> toMlConversion = {
    'oz': 29.5735, // oz: Onça líquida (fluid ounce)
    'onça': 29.5735, // onça: Onça líquida (fluid ounce) em português
    'onças': 29.5735,
    'cl': 10, // cl: Centilitro
    'ml': 1, // ml: Mililitro
    'cup': 236.588, // cup: Xícara (cup)
    'tsp': 4.92892, // tsp: Colher de chá (teaspoon)
    'tbsp': 14.7868, // tbsp: Colher de sopa (tablespoon)
    'shot': 44.36, // shot: Dose (shot)
    'dash': 0.92, // dash: Pitada (dash)
    'splash': 3.7, // splash: Pequena quantidade (splash)
    'jigger': 44.36, // jigger: Medida de coquetel (jigger)
  };

  static RegExp measurementRegex = RegExp(
      r'(\d+(?:/\d+)?|\d*\.\d+)\s*(oz|cl|ml|cup|tsp|tbsp|shot|dash|splash|jigger)',
      caseSensitive: false);

  static double fractionToDecimal(String fraction) {
    if (fraction.contains('/')) {
      final parts = fraction.split('/');
      return double.parse(parts[0]) / double.parse(parts[1]);
    }
    return double.parse(fraction);
  }

  static (double, String) parseMeasurement(String measure) {
    final match = measurementRegex.firstMatch(measure.toLowerCase());
    if (match == null) return (0, measure);

    final amount = fractionToDecimal(match.group(1)!);
    final unit = match.group(2)!.toLowerCase();

    return (amount, unit);
  }

  static String convertToMl(String measure) {
    final (amount, unit) = parseMeasurement(measure);
    if (amount == 0) return measure;

    if (toMlConversion.containsKey(unit)) {
      final mlValue = amount * toMlConversion[unit]!;
      return '${mlValue.toStringAsFixed(1)} ml';
    }

    return measure;
  }
}
