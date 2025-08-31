import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your courses.")),
      );
    }
    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        backgroundColor: Colors.deepOrangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .where('students', arrayContains: uid) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "You haven’t registered for any courses yet.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final courses = snapshot.data!.docs
              .map((doc) => Course.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange),
                      ),
                      const SizedBox(height: 4),
                      Text(course.description),
                      Text("Credits: ${course.credits}"),
                      Text("Instructor: ${course.instructor}"),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('courses')
                            .doc(course.id)
                            .collection('assignments')
                            .snapshots(),
                        builder: (context, assignSnapshot) {
                          if (!assignSnapshot.hasData ||
                              assignSnapshot.data!.docs.isEmpty) {
                            return const Text("No assignments yet");
                          }

                          final assignments = assignSnapshot.data!.docs;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: assignments.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>;
                              final grades = List.from(data['grades'] ?? []);

                       
                              final studentGrade = grades.firstWhere(
                                  (g) => g['studentId'] == uid,
                                  orElse: () => null);

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(data['title'] ?? 'Untitled',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Text(studentGrade != null
                                        ? "${studentGrade['grade']}"
                                        : "Not graded"),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      )
                    ],
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
