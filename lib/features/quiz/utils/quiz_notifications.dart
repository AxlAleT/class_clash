import 'package:flutter/material.dart';

/// Utility class for showing quiz-related notifications
class QuizNotifications {
  /// Shows a toast-style message
  static void showToast(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: 10.0,
        right: 10.0,
        child: Material(
          elevation: 10.0,
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: textColor),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  /// Shows a success notification
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      context,
      message,
      backgroundColor: Colors.green.shade700,
      duration: duration,
    );
  }

  /// Shows an error notification
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      context,
      message,
      backgroundColor: Colors.red.shade700,
      duration: duration,
    );
  }
}
