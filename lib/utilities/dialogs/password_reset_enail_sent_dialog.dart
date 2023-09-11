import 'package:flutter/material.dart';
import 'package:project_remembrance/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Password Reset',
      content: 'An email for resetting password has been sent. Please check your email.',
      optionsBuilder: () => {
        'OK' : null,
      },
  );
}