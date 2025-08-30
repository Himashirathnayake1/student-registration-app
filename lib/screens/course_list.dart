import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_registration_system/custom/custom_button.dart';

import '../models/course.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  Future<void> _registerForCourse(String courseId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final courseRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId);

    await courseRef.update({
      'students': FieldValue.arrayUnion([uid]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Courses"),
        backgroundColor: Colors.deepOrangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange,));
          }

          final courses =
              snapshot.data!.docs
                  .map(
                    (doc) => Course.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList();

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                     elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    course.name,
                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                  ),
                  subtitle: Text(
                    "${course.description}\nCredits: ${course.credits}\nInstructor: ${course.instructor}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  isThreeLine: true,
                  trailing: CustomButton(
                    text: "Register",
                    onPressed: () async {
                      await _registerForCourse(course.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "You registered for ${course.name}! 🎉",
                          ),
                          backgroundColor: Colors.orangeAccent,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
