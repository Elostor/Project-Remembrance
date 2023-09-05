import 'package:flutter/material.dart';
import 'package:project_remembrance/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Log out',
      content: 'Are you sure you want to log out?',
      optionsBuilder: () => {
        'Cancel': false,
        'Log Out': true,
      },
  ).then((value) => value ?? false);
  // On some platforms, user has to click onto one of the buttons
  // to dismiss a dialog or to proceed with it; which means that the dialog
  // that user sees either returns 'true' or 'false'.
  // On some platforms it can return 'null'.
  // 'then()' function is a safety method here.
}