import 'package:flutter/material.dart';

Future<void> showConfirmDialog(BuildContext context, {
  required String title,
  required String content,
  required VoidCallback onConfirmed,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: const Text("Batal"),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          child: const Text("Ya"),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if (result == true) {
    onConfirmed();
  }
}
