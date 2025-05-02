import 'package:flutter/material.dart';
import 'payment.dart'; // ✅ Make sure this exists

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlanCard(
            context,
            icon: Icons.construction,
            title: 'Wet Plant Hire',
            price: '\$19.99/month',
            description: 'First month free\nPost ads for hiring wet machinery',
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            context,
            icon: Icons.precision_manufacturing,
            title: 'Dry Plant Hire',
            price: '\$19.99/month',
            description: 'First month free\nPost ads for hiring dry machinery',
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            context,
            icon: Icons.engineering,
            title: 'Wet/Dry Plant Hire',
            price: '\$29.99/month',
            description: 'First month free\nPost ads for labour jobs',
          ),
          const SizedBox(height: 16),
          _buildPlanCard(
            context,
            icon: Icons.assignment,
            title: 'Lump Sum Contractor',
            price: '\$99.00/month',
            description: 'Post contracting services',
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String price,
        required String description,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 36, color: Colors.amber[800]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(
                      planName: title,
                      price: price,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("Click here to subscribe"),
            ),
          ),
        ],
      ),
    );
  }
}
