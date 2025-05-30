// lib/screens/policy_page.dart

import 'package:flutter/material.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy / Legal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            '''
Costa Civil – Terms & Policies

1. Terms of Service
   • You agree to use this app only for lawful purposes.  
   • You must not reverse-engineer, decompile, or tamper with the software.  
   • We reserve the right to suspend or terminate your account for violations.

2. Privacy Policy
   • We collect only the personal information you provide (name, email, phone).  
   • Your data is stored securely in Firebase and not shared with third parties.  
   • You can request deletion of your account and data at any time via settings.

3. Refund & Cancellation
   • All subscription and payment terms are governed by Stripe’s policies.  
   • Refund requests must be submitted within 7 days via support@costacivil.com.

4. Intellectual Property
   • All content (text, graphics, logos) is the property of Costa Civil.  
   • You may not reproduce, modify, or distribute our trademarks without permission.

5. Liability Disclaimer
   • Costa Civil provides no warranties regarding the accuracy of listings or ads.  
   • We are not liable for any damages arising from use of this app.

6. Changes to Policies
   • We may update these Terms & Policies at any time.  
   • Continued use after changes implies acceptance.

If you have questions or need support, please contact us at:
support@costacivil.com
+61 1234 5678

© 2025 Costa Civil. All rights reserved.
            ''',
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
