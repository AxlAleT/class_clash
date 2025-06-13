import 'package:flutter/material.dart';

class DialogUtils {
  /// Shows a confirmation dialog with customizable messages and button text
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Yes',
    String cancelText = 'No',
    bool barrierDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Shows an unsaved changes confirmation dialog
  static Future<bool> showUnsavedChangesDialog(BuildContext context) async {
    return showConfirmationDialog(
      context: context,
      title: 'Unsaved Changes',
      content: 'You have unsaved changes. Are you sure you want to discard them?',
      confirmText: 'Discard',
      cancelText: 'Keep Editing',
    );
  }

  /// Shows a quit quiz confirmation dialog
  static Future<bool> showQuitQuizDialog(BuildContext context) async {
    return showConfirmationDialog(
      context: context,
      title: 'Quit Quiz',
      content: 'Are you sure you want to quit this quiz? Your progress will be lost.',
      confirmText: 'Quit',
      cancelText: 'Continue',
    );
  }
}
