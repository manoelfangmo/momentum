/// Field rules for the sign-in and sign-up forms. Null means valid, which is
/// what `TextFormField.validator` expects.
library;

/// Matches `auth.minimum_password_length` in `supabase/config.toml`, so the
/// form rejects a short password before Supabase does.
const minPasswordLength = 6;

const maxNameLength = 40;

/// Deliberately loose: one `@`, a dot in the domain, no spaces. Anything
/// stricter rejects addresses that are in fact deliverable.
final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address.';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address.';
  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Enter a password.';
  if (password.length < minPasswordLength) {
    return 'Use at least $minPasswordLength characters.';
  }
  return null;
}

String? validateName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Enter your name.';
  if (name.length > maxNameLength) {
    return 'Use $maxNameLength characters or fewer.';
  }
  return null;
}
