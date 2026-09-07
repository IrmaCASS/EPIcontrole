import 'package:flutter/material.dart';

class DiarioScreen extends StatelessWidget {
  const DiarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 80, color: Colors.blueAccent),
          SizedBox(height: 16),
          Text(
            'Meu Diário',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Diario de crises'),
        ],
      ),
    );
  }
}