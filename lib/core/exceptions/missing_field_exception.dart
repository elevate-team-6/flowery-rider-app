/// Thrown when a response model is missing a field that is required to build
/// its domain entity. This surfaces malformed/incomplete backend payloads at
/// the data → domain mapping boundary, instead of leaking nullable values into
/// the domain layer.
class MissingFieldException implements Exception {
  /// Name of the missing field (e.g. `id`, `firstName`).
  final String field;

  /// Type the field belongs to (e.g. `DriverResponseModel`).
  final String owner;

  const MissingFieldException(this.field, {required this.owner});

  @override
  String toString() =>
      'MissingFieldException: required field "$field" was null in $owner';
}

/// Returns [value] if it is non-null and (for strings) non-empty, otherwise
/// throws a [MissingFieldException] describing [field] on [owner].
T requireField<T>(T? value, String field, {required String owner}) {
  if (value == null || (value is String && value.isEmpty)) {
    throw MissingFieldException(field, owner: owner);
  }
  return value;
}
