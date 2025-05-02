import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email.text = prefs.getString('email') ?? '';
      _password.text = prefs.getString('password') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', _email.text.trim());
      await prefs.setString('password', _password.text.trim());
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final user = userCredential.user;
      if (user != null && !user.emailVerified) {
        setState(() {
          _errorMessage = 'Email is not verified. Please check your inbox.';
        });
        return;
      }

      await _saveCredentials();

      Navigator.pushReplacementNamed(context, '/Homepage_contractor');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = switch (e.code) {
          'user-not-found' => 'No user found for this email.',
          'wrong-password' => 'Incorrect password.',
          'invalid-email' => 'Invalid email address.',
          _ => 'Login failed. ${e.message}',
        };
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      setState(() {
        _errorMessage = 'Enter your registered email to reset password.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending reset email: $e';
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: const [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black,
                            child: Text('C', style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(width: 8),
                          Text("COSTA", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text("CIVIL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      SizedBox(height: 40),
                      Text("LOGIN", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                  ),

                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains("@")) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your password";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                    ),
                    const Text("Remember me"),
                    const Spacer(),
                    TextButton(
                      onPressed: _resetPassword,
                      child: const Text("Forgot password?", style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("LOG IN", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.yellow),
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("SIGN UP", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
