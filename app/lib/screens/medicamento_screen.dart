import 'package:flutter/material.dart';

class MedicamentoScreen extends StatelessWidget {
  const MedicamentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services, size: 80, color: Colors.redAccent),
          SizedBox(height: 16),
          Text(
            'Medicamentos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Aqui ficarão os alarmes e remédios.'),
        ],
      ),
    );
  }
}