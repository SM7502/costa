import 'package:flutter/material.dart';

class WetPlantHireDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const WetPlantHireDetailsPage({super.key, required this.data});

  void _showContactDialog(BuildContext context) {
    final contact = data['contact_preference'] ?? 'No contact info available';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Contact Details'),
        content: Text(contact),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(data['machine_item'] ?? 'Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FIXED IMAGE PART
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.construction, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'For Hire: ${data['machine_item'] ?? ''}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business, size: 20),
                const SizedBox(width: 5),
                Text(data['company_name'] ?? ''),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 5),
                Text(data['location'] ?? ''),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Add to Favourites'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showContactDialog(context),
                    child: const Text('Contact'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Further Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Hire Rate Option: ${data['hire_rate_option'] ?? ''}'),
            Text('Rates: \$${data['min_rate']} - \$${data['max_rate']}'),
            const SizedBox(height: 10),
            const Text('✔ Fuel-efficient and GPS-enabled'),
            const Text('✔ Available for wet or dry hire'),
            const Text('✔ Suitable for commercial and residential use'),
          ],
        ),
      ),
    );
  }
}
