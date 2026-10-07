/// Field rules for the two onboarding cards. Null means valid, which is what
/// `TextFormField.validator` expects.
library;

import 'package:app/core/utils/uuid.dart';

/// Matches the `char_length(name) between 1 and 60` check on `public.groups`,
/// so the form rejects a long name before Postgres does.
const maxGroupNameLength = 60;

String? validateGroupName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Enter a name for the group.';
  if (name.length > maxGroupNameLength) {
    return 'Use $maxGroupNameLength characters or fewer.';
  }
  return null;
}

/// An invite code is the group's id, so the only shape worth accepting is a
/// uuid. Whether a group has that id is the database's answer, not this one's.
String? validateGroupCode(String? value) {
  final code = value?.trim() ?? '';
  if (code.isEmpty) return 'Paste the invite code you were sent.';
  if (!isUuid(code)) return 'That does not look like an invite code.';
  return null;
}
