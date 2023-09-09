import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
required BuildContext context,
required String text
}) {
  bool canceledOperation = false;
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10.0),
        Text(text),
        const SizedBox(height: 10.0),
        ElevatedButton(
            onPressed: () {
              canceledOperation = true;
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('Cancel'),
        )
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return dialog;
    },
  );

  if (!canceledOperation){
    return () => Navigator.of(context).pop();
  } else {
    canceledOperation = false;
    return () {};
  }

}