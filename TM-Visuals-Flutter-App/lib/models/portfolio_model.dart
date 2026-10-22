/// Thrown for problems we can explain to the user in plain words.
class PortfolioError implements Exception {
  const PortfolioError(this.message);
  final String message;
}
