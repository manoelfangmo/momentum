import 'package:app/core/utils/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Puts the invite code on the clipboard.
///
/// A copy leaves nothing on screen, so the toast is the only confirmation the
/// member gets that the code is theirs to paste.
class CopyGroupCodeButton extends StatelessWidget {
  const CopyGroupCodeButton({super.key, required this.code});

  final String code;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    showSuccessToast(context, 'Invite code copied.');
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _copy(context),
      icon: const Icon(Icons.copy_outlined),
      label: const Text('Copy invite code'),
    );
  }
}
