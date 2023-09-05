import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want delete this note?',
    optionsBuilder: () =>
    {
      'Cancel': false,
      'Yes': true,
    },
  ).then((value) => value ?? false);
}