import 'package:flutter/material.dart';

class SubscriptionSummaryPage extends StatelessWidget {
  final String planName;
  final String status;
  final String trialEndDate;

  const SubscriptionSummaryPage({
    Key? key,
    required this.planName,
    required this.status,
    required this.trialEndDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'active' ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Summary'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Plan: $planName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Status: ', style: TextStyle(fontSize: 18)),
                Text(
                  status,
                  style: TextStyle(fontSize: 18, color: statusColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Trial Ends On: $trialEndDate',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
