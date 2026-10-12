

String cleanDxfMText(String text) {
  var result = text;

  // Remove outer formatting groups like {\fArial|b0|i0|c163|p34;...}
  result = result.replaceAll(RegExp(r'\\f[^;]*;'), '');

  // Remove character width and tracking overrides.
  result = result.replaceAll(RegExp(r'\\[WwTt][^;]*;'), '');

  // Remove overline, underline, and strike-through toggles.
  result = result.replaceAll(RegExp(r'\\[OoLlKk]'), '');

  // Convert common MTEXT controls.
  result = result
      .replaceAll(r'\P', '\n')
      .replaceAll(r'\~', ' ')
      .replaceAll(r'\{', '{')
      .replaceAll(r'\}', '}');

  // Strip grouping braces used for MTEXT formatting.
  result = result.replaceAll('{', '').replaceAll('}', '');

  return result;
}
