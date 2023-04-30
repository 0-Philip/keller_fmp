void main() {}

List<String> parseField(final String stringWithSeparators) {
  return stringWithSeparators
      .split('[,;]')
      .map((adress) => adress.trim())
      .where((element) => element.isNotEmpty)
      .toList();
}

bool containsSeparators(final String maybeHasSeparators) {
  return maybeHasSeparators.contains('[,;]') ? true : false;
}

List<String> parseField2(final String inputString) {
  return containsSeparators(inputString)
      ? parseField(inputString)
      : [inputString];
}
