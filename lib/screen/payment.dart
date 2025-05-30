import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'subscription_summary.dart';
import 'package:flutter/services.dart';

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2) formatted += '/';
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


class PaymentPage extends StatefulWidget {
  final String planName;
  final String price;

  const PaymentPage({Key? key, required this.planName, required this.price}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;
  bool _isSubscribed = false;
  bool _isCancelled = false;
  DateTime? _trialEndDate;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('subscriptions')
          .doc(user.uid)
          .collection('plans')
          .doc(widget.planName)
          .get();

      if (doc.exists) {
        setState(() {
          _isSubscribed = doc['status'] == 'active';
          _isCancelled = doc['status'] == 'cancelled';
          _trialEndDate = (doc['trialEndsAt'] as Timestamp).toDate();
        });
      }
    } catch (e) {
      debugPrint('Error checking subscription: $e');
    }
  }

  Future<void> _handlePayment() async {
    final name = _nameController.text.trim();
    final card = _cardNumberController.text.trim();
    final expiry = _expiryController.text.trim();
    final cvv = _cvvController.text.trim();

    // 1. Field empty check
    if (name.isEmpty || card.isEmpty || expiry.isEmpty || cvv.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    // 2. Card number validation: exactly 16 digits
    if (!RegExp(r'^\d{16}$').hasMatch(card)) {
      setState(() => _errorMessage = 'Card number must be exactly 16 digits.');
      return;
    }

    // 3. Expiry format check
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
      setState(() => _errorMessage = 'Expiry date must be in MM/YY format.');
      return;
    }

    // 4. Expiry date must not be in the past
    final parts = expiry.split('/');
    final int month = int.tryParse(parts[0]) ?? 0;
    final int year = int.tryParse(parts[1]) ?? 0;

    if (month < 1 || month > 12) {
      setState(() => _errorMessage = 'Invalid expiry month.');
      return;
    }

    final now = DateTime.now();
    final expiryDate = DateTime(2000 + year, month + 1, 0);
    if (expiryDate.isBefore(now)) {
      setState(() => _errorMessage = 'Card has already expired.');
      return;
    }

    // 5. CVV validation: exactly 3 digits
    if (!RegExp(r'^\d{3}$').hasMatch(cvv)) {
      setState(() => _errorMessage = 'CVV must be exactly 3 digits.');
      return;
    }

    // Save subscription
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');

      final trialEndDate = DateTime(now.year, now.month + 1, now.day, now.hour, now.minute);
      final formattedTrialDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(trialEndDate);

      await FirebaseFirestore.instance
          .collection('subscriptions')
          .doc(user.uid)
          .collection('plans')
          .doc(widget.planName)
          .set({
        'uid': user.uid,
        'plan': widget.planName,
        'price': widget.price,
        'nameOnCard': name,
        'cardLast4': card.substring(12),
        'startDate': Timestamp.now(),
        'trialEndsAt': trialEndDate,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSubscribed = true;
        _isCancelled = false;
        _trialEndDate = trialEndDate;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SubscriptionSummaryPage(
            planName: widget.planName,
            status: 'active',
            trialEndDate: formattedTrialDate,
          ),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error saving subscription: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _cancelSubscription() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = FirebaseFirestore.instance
          .collection('subscriptions')
          .doc(user.uid)
          .collection('plans')
          .doc(widget.planName);

      final doc = await docRef.get();
      if (doc.exists && doc['status'] == 'active') {
        await docRef.update({'status': 'cancelled'});
        setState(() {
          _isSubscribed = false;
          _isCancelled = true;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SubscriptionSummaryPage(
              planName: widget.planName,
              status: 'cancelled',
              trialEndDate: _trialEndDate != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_trialEndDate!)
                  : 'Unknown',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '❌ Error cancelling subscription: $e';
      });
    }
  }

  Future<void> _reactivateSubscription() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = FirebaseFirestore.instance
          .collection('subscriptions')
          .doc(user.uid)
          .collection('plans')
          .doc(widget.planName);

      final doc = await docRef.get();
      if (doc.exists && doc['status'] == 'cancelled') {
        await docRef.update({'status': 'active'});
        setState(() {
          _isSubscribed = true;
          _isCancelled = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SubscriptionSummaryPage(
              planName: widget.planName,
              status: 'reactivated',
              trialEndDate: _trialEndDate != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_trialEndDate!)
                  : 'Unknown',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '❌ Error reactivating subscription: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Payment for ${widget.planName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                color: Colors.red[100],
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Enter Full name on Card'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardNumberController,
              decoration: const InputDecoration(labelText: 'Card Number'),
              keyboardType: TextInputType.number,
              maxLength: 16,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _expiryController,
              decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(5),
                ExpiryDateFormatter(),
              ],
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _cvvController,
              decoration: const InputDecoration(labelText: 'CVV'),
              keyboardType: TextInputType.number,
              maxLength: 3,
            ),
            const SizedBox(height: 24),
            if (!_isSubscribed && !_isCancelled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Pay Now (Start 1 Month Free Trial)'),
                ),
              ),
            if (_isSubscribed)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _cancelSubscription,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Cancel Subscription'),
                ),
              ),
            if (_isCancelled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _reactivateSubscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Reactivate Subscription'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
