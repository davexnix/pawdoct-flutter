String toPascalCase(String input) {
  return input
      .split(RegExp(r'[\s_\-]+'))
      .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

String ucfirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

bool isNumeric(String s) {
  if (s.isEmpty) return false;
  return double.tryParse(s) != null;
}
