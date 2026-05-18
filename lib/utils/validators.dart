bool isValidEmail(String email) {
  final trimmed = email.trim();
  return trimmed.contains('@') && trimmed.contains('.') && trimmed.length > 5;
}
