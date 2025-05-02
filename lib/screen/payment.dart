import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'subscription_summary.dart';

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
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');

      final now = DateTime.now();
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
        'nameOnCard': _nameController.text.trim(),
        'cardLast4': _cardNumberController.text.trim().substring(_cardNumberController.text.length - 4),
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
                color: _errorMessage!.startsWith('✅') ? Colors.green[100] : Colors.red[100],
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
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _expiryController,
              decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cvvController,
              decoration: const InputDecoration(labelText: 'CVV'),
              keyboardType: TextInputType.number,
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
