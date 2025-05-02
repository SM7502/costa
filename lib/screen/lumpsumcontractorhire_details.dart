import 'package:flutter/material.dart';

class LumpSumContractorDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const LumpSumContractorDetailsPage({super.key, required this.data});

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
      appBar: AppBar(title: Text(data['company_name'] ?? 'Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business_center, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'Service: ${data['service_category'] ?? ''}',
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
                    onPressed: () {
                      final url = data['capability_pdf_url'];
                      if (url != null && url.toString().startsWith('http')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(title: const Text("Capability PDF")),
                              body: Center(child: Text("Open this PDF:") // Placeholder
                              ),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No capability PDF available")),
                        );
                      }
                    },
                    child: const Text('View Capability PDF'),
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
            const Text('✔ Registered and certified'),
            const Text('✔ Available for project-based contracts'),
            const Text('✔ Trusted by commercial builders'),
          ],
        ),
      ),
    );
  }
}
