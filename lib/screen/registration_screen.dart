import 'package:flutter/material.dart';
// import 'home_screen.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _company = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - kToolbarHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // 🔥 Logo
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black,
                                child: Text('C', style: TextStyle(color: Colors.white)),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "COSTA",
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                            ],
                          ),
                          const Text(
                            "CIVIL",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 2),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "REGISTER",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField("First Name", _firstName),
                      _buildTextField("Last Name", _lastName),
                      _buildTextField("Email", _email, inputType: TextInputType.emailAddress, validator: (value) {
                        if (!value!.contains('@gmail.com')) return 'Enter a valid @gmail.com email';
                        return null;
                      }),
                      _buildTextField("Phone Number", _phone, inputType: TextInputType.phone, validator: (value) {
                        if (value!.length != 10) return 'Phone must be 10 digits';
                        return null;
                      }),
                      _buildTextField("Company Name (Optional)", _company, required: false),
                      _buildTextField("Password", _password, isPassword: true, validator: (value) {
                        if (value!.length < 6 || !RegExp(r'(?=.*[0-9])(?=.*[!@#\$%^&*])').hasMatch(value)) {
                          return 'Use at least 6 characters with number & special char';
                        }
                        return null;
                      }),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value!;
                              });
                            },
                          ),
                          const Flexible(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: "I agree to the "),
                                  TextSpan(
                                    text: "Terms of Use",
                                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                  ),
                                  TextSpan(text: " and Privacy Policy"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      OutlinedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (!_agreeToTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('You must agree to terms to continue')),
                              );
                              return;
                            }

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.yellow),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text("SIGN UP", style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint,
      TextEditingController controller, {
        TextInputType inputType = TextInputType.text,
        bool isPassword = false,
        bool required = true,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: validator ??
            (required
                ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
                : null),
      ),
    );
  }
}
