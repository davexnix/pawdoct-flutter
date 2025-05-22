import 'package:flutter/widgets.dart';

Widget pawdoctLogo() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Image.asset(
          'assets/images/logo.png',
          height: 400, // Ukuran bisa disesuaikan
        ),
      ),
      const Text(
        'PAWDOCT',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          height: -10, // memperkecil jarak antar baris teks
        ),
      ),
    ],
  );
}
