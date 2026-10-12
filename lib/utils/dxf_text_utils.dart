
String cleanDxfText(String text) {
  return text
  // Remove font declarations, such as \fNoto Sans|b0|i0|c0|p0;
      .replaceAll(RegExp(r'\\f[^;]*;'), '')
  // Remove width and tracking overrides.
      .replaceAll(RegExp(r'\\[WwTt][^;]*;'), '')
  // Remove overline and underline controls.
      .replaceAll(RegExp(r'\\[OoLlKk]'), '')
  // Convert paragraph breaks and nonbreaking spaces.
      .replaceAll(r'\P', '\n')
      .replaceAll(r'\~', ' ')
  // Unescape escaped backslashes.
      .replaceAll(r'\\', r'\');
}