class ValidatorResult {
  final bool ok;
  final List<String> errors;

  const ValidatorResult._(this.ok, this.errors);

  factory ValidatorResult.ok() => const ValidatorResult._(true, []);
  factory ValidatorResult.fail(List<String> errors) =>
      ValidatorResult._(false, List.unmodifiable(errors));
}
