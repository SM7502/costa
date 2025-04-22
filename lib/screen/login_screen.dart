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
                    } else if (!RegExp(r'(?=.*[0-9])(?=.*[!@#$%^&*])').hasMatch(value)) {
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

                // LOG IN
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushNamed(context, '/Homepage_contractor');
                    }
                  },
                  child: const Text("LOG IN", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                // SIGN UP
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

//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _email = TextEditingController();
//   final TextEditingController _password = TextEditingController();
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _email.text.trim(),
//         password: _password.text.trim(),
//       );
//       if (mounted) {
//         final uid = FirebaseAuth.instance.currentUser?.uid;
//         final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//
//         if (doc.exists) {
//           final userData = doc.data(); // It's a Map<String, dynamic>
//
//           Navigator.pushNamed(
//             context,
//             '/Homepage_contractor',
//             arguments: userData, // Pass the user data
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("User data not found")),
//           );
//         }
//
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage;
//       switch (e.code) {
//         case 'user-not-found':
//           errorMessage = 'No user found for this email.';
//           break;
//         case 'wrong-password':
//           errorMessage = 'Incorrect password.';
//           break;
//         case 'invalid-email':
//           errorMessage = 'The email address is invalid.';
//           break;
//         default:
//           errorMessage = 'Login failed: ${e.message}';
//       }
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _email.dispose();
//     _password.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: ListView(
//               children: [
//                 const SizedBox(height: 60),
//                 Center(
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           CircleAvatar(
//                             radius: 20,
//                             backgroundColor: Colors.black,
//                             child: Text('C', style: TextStyle(color: Colors.white)),
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             "COSTA",
//                             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
//                           ),
//                         ],
//                       ),
//                       const Text(
//                         "CIVIL",
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 2),
//                       ),
//                       const SizedBox(height: 40),
//                       const Text(
//                         "LOGIN",
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 TextFormField(
//                   controller: _email,
//                   decoration: const InputDecoration(
//                     labelText: "Login",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || !value.contains("@gmail.com")) {
//                       return "Email must include @gmail.com";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _password,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     labelText: "Password",
//                     border: const OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
//                       onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Enter password";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       // TODO: Implement forgot password
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Forgot password not implemented yet')),
//                       );
//                     },
//                     child: const Text(
//                       "Forgot password?",
//                       style: TextStyle(color: Colors.blue),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.yellow[700],
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     foregroundColor: Colors.white,
//                   ),
//                   onPressed: _isLoading ? null : _login,
//                   child: _isLoading
//                       ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                   )
//                       : const Text("LOG IN", style: TextStyle(fontSize: 16)),
//                 ),
//                 const SizedBox(height: 16),
//                 OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     side: const BorderSide(color: Colors.yellow),
//                     backgroundColor: Colors.yellow[700],
//                     foregroundColor: Colors.white,
//                   ),
//                   onPressed: () => Navigator.pushNamed(context, '/register'),
//                   child: const Text("SIGN UP", style: TextStyle(fontSize: 16)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }