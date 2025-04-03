import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

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
                    children: [
                      // Logo + Title
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
                      const SizedBox(height: 40),
                      const Text(
                        "LOGIN",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: "Login"),
                  validator: (value) {
                    if (value == null || !value.contains("@gmail.com")) {
                      return "Email must include @gmail.com";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter password";
                    } else if (!RegExp(r'(?=.*[0-9])(?=.*[!@#\$%^&*])').hasMatch(value)) {
                      return "Use number & special char";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // LOGIN button (Yellow bg, white text)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print("Login success!");
                    }
                  },
                  child: const Text("LOG IN", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                // SIGN UP button (Outlined yellow, white text)
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
