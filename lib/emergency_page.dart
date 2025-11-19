import 'package:flutter/material.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚨 دلني عاجل'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.medical_services, color: Colors.redAccent, size: 80),
              SizedBox(height: 20),
              Text(
                'دلني عاجل — خدمتك السريعة للطوارئ على الطريق 🚑',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'قريبًا سيتم تفعيل هذه الخدمة لعرض أقرب رافعة أو مركز صيانة بناءً على موقعك الجغرافي.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
