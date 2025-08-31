import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_registration_system/custom/custom_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '', email = '', studentId = '', password = '';
  bool isLoading = false;

  Future<void> registerStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

  
      await FirebaseFirestore.instance
          .collection('students')
          .doc(userCredential.user!.uid)
          .set({'name': name, 'email': email, 'studentId': studentId});

      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration Successful!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 110),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  onChanged: (val) => name = val,
                  validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (val) => email = val,
                  validator: (val) => val!.isEmpty ? 'Enter your email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Student ID'),
                  onChanged: (val) => studentId = val,
                  validator: (val) => val!.isEmpty ? 'Enter Student ID' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password must include Capital Letter, Special character and Number '),
                  obscureText: true,
                  onChanged: (val) => password = val,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter a password';
                    if (val.length < 6)
                      return 'Password must be at least 6 characters';
                    if (!RegExp(r'[A-Z]').hasMatch(val)) {
                      return 'Password must contain at least one capital letter';
                    }
                    if (!RegExp(r'\d').hasMatch(val)) {
                      return 'Password must contain at least one number';
                    }
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(val)) {
                      return 'Password must contain at least one special character';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                CustomButton(
                  text: 'Register',
                  onPressed: registerStudent,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Already have an account? Login',style: TextStyle(color: Colors.black),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
