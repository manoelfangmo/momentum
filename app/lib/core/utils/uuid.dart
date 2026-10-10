/// Whether [value] has the shape of a Postgres `uuid`.
///
/// A group's invite code is its id, so a mistyped code is caught here before
/// it reaches PostgREST, where a bad uuid comes back as a parse failure rather
/// than as the `group_not_found` the user needs to read.
library;

final _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

bool isUuid(String value) => _uuidPattern.hasMatch(value);
