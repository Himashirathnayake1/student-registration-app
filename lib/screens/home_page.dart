import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_registration_system/screens/course_list.dart';
import 'package:student_registration_system/screens/login_screen.dart';
import 'package:student_registration_system/screens/my_courses.dart';
import 'package:student_registration_system/screens/profile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.deepOrangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 80),
              FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('students')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                'Hello, Student!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              );
            }
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Student';
              return Text(
                'Hello, $name!',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              );
              
            } else {
              return const Text(
                'Hello, Student!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              );
            }
          },
         
        ),
        const SizedBox(height: 30),
        _buildCard(
          context,
          title: "Browse Courses",
          subtitle: "Find and register for available courses",
          icon: Icons.school,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseListScreen()));
                },
              ),
              const SizedBox(height: 20),
              _buildCard(
                context,
                title: "My Courses",
                subtitle: "View your registered courses",
                icon: Icons.book,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCoursesScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.deepOrange.withOpacity(0.1),
                child: Icon(icon, size: 32, color: Colors.deepOrange),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 18, color: Colors.deepOrange),
            ],
          ),
        ),
      ),
    );
  }
}
