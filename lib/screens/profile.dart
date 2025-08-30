import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_registration_system/custom/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String name = '';
  String email = '';
  String studentId = '';

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (user == null) return;
    setState(() => isLoading = true);

    final doc =
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user!.uid)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      name = data['name'] ?? '';
      email = data['email'] ?? '';
      studentId = data['studentId'] ?? '';
      setState(() {});
    }

    setState(() => isLoading = false);
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(user!.uid)
          .update({'name': name, 'email': email});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepOrangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange,))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 110),
                      TextFormField(
                        initialValue: name,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                        ),
                        onChanged: (val) => name = val,
                        validator:
                            (val) => val!.isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: email,
                        decoration: const InputDecoration(labelText: 'Email'),
                        onChanged: (val) => email = val,
                        validator:
                            (val) => val!.isEmpty ? 'Enter your email' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: studentId,
                        decoration: const InputDecoration(
                          labelText: 'Student ID',
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        text: 'Update Profile',
                        onPressed: _updateProfile,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
