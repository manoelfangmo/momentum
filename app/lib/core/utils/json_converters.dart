import 'package:json_annotation/json_annotation.dart';

/// Carries a `timestamptz` across the boundary: UTC in Postgres, local in Dart.
///
/// Postgres sends an offset-carrying string, so [DateTime.parse] already lands
/// on the right instant; [DateTime.toLocal] is what puts period math and date
/// labels in the member's own calendar day. Writes go the other way and always
/// send UTC, whatever zone the [DateTime] was built in.
class LocalDateTimeConverter implements JsonConverter<DateTime, String> {
  const LocalDateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toLocal();

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}
