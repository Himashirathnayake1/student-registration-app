import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});
    Future<List<Map<String, String>>> _fetchAssignmentsWithGrade(String courseId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, String>> result = [];

    try {
      // Get all assignments for this course
      final assignmentSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('assignments')
          .get();

      for (var assignmentDoc in assignmentSnapshot.docs) {
        final assignmentId = assignmentDoc.id;

        // Get all grade documents inside this assignment
        final gradesSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('assignments')
            .doc(assignmentId)
            .collection('grades')
            .get();

        for (var gradeDoc in gradesSnapshot.docs) {
          final students = List<String>.from(gradeDoc.data()['students'] ?? []);
          if (students.contains(uid)) {
            // If current user is in this grade
            result.add({
              'assignment': assignmentId,
              'grade': gradeDoc.id, // document id is grade (A, B, C)
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching assignments with grade: $e");
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

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
            .where('students', arrayContains: uid) // ✅ only my courses
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
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
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                onTap: () async {
                    // fetch assignments with grade
                    final assignmentsWithGrade = await _fetchAssignmentsWithGrade(course.id);

                    if (assignmentsWithGrade.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No grades available for you yet.")),
                      );
                      return;
                    }

                    // Show in bottom sheet
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return ListView.builder(
                          itemCount: assignmentsWithGrade.length,
                          itemBuilder: (context, i) {
                            final item = assignmentsWithGrade[i];
                            return ListTile(
                              title: Text("Assignment: ${item['assignment']}"),
                              subtitle: Text("Your Grade: ${item['grade']}"),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}