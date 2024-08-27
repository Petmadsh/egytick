import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  TextEditingController? nameController;
  TextEditingController? emailController;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      nameController = TextEditingController(text: user?.displayName ?? '');
      emailController = TextEditingController(text: user?.email ?? '');
      fetchAdditionalUserData();
    }
  }

  Future<void> fetchAdditionalUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user?.uid).get();
    if (userDoc.exists) {
      setState(() {
        nameController?.text = userDoc['name'] ?? user?.displayName ?? '';
      });
    }
  }

  Future<void> updateProfile() async {
    if (user != null) {
      try {
        await user?.updateDisplayName(nameController?.text);
        await user?.updateEmail(emailController?.text ?? '');

        // Update additional data in Firestore if necessary
        await _firestore.collection('users').doc(user?.uid).set({
          'name': nameController?.text,
          'email': emailController?.text,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 40,
        selectedItemColor: Colors.orange,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
            );
          }

        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
      body: user == null
          ? Center(child: Text('No user signed in'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfile,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
