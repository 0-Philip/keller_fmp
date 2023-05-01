void main() {
  var list = parseField("philipugk@gmail.com, philipugk@icloud.com");
  print(list);
  print(list.length);
  print(containsSeparators("philipugk@gmail.com, philipugk@icloud.com"));
  print(separateAdresses("philipugk@gmail.com, philipugk@icloud.com").length);
}

List<String> separateAdresses(final String stringWithSeparators) {
  return stringWithSeparators
      .split(RegExp(r'[,;]'))
      .map((adress) => adress.trim())
      .where((element) => element.isNotEmpty)
      .toList();
}

bool containsSeparators(final String maybeHasSeparators) {
  return maybeHasSeparators.contains(RegExp(r'[,;]')) ? true : false;
}

List<String> parseField(final String inputString) {
  return containsSeparators(inputString)
      ? separateAdresses(inputString)
      : [inputString];
}
