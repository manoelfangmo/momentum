/// Field rules for the new goal sheet. Null means valid, which is what
/// `TextFormField.validator` expects.
library;

/// Matches the `char_length(title) between 1 and 140` check on `public.goals`,
/// so the sheet rejects a long title before Postgres does.
const maxGoalTitleLength = 140;

/// The title is trimmed before it is measured, so spaces alone are empty and a
/// title that only fits once trimmed is accepted — which is what the service
/// sends.
String? validateGoalTitle(String? value) {
  final title = value?.trim() ?? '';
  if (title.isEmpty) return 'Say what you want to get done.';
  if (title.length > maxGoalTitleLength) {
    return 'Use $maxGoalTitleLength characters or fewer.';
  }
  return null;
}
