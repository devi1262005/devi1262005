import 'package:flutter/material.dart';
import 'home.dart';
import 'documents.dart';
import 'package:firebase_core/firebase_core.dart';
import 'personal.dart';
import 'ToDoPage.dart';
import 'Notepad.dart'; // Import the Notepad.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: 'AIzaSyAwmbLuh2qG5mvit3TxKBnPly-eURxhkfw',
    authDomain: 'verily-app.firebaseapp.com', // Replace with your authDomain
    databaseURL: 'https://verily-app-default-rtdb.asia-southeast1.firebasedatabase.app',
    projectId: 'verily-app',
    storageBucket: 'verily-app.appspot.com',
    messagingSenderId: '1020180429209',
    appId: '1:1020180429209:android:8905d137c8841ad2bb7b08',
    measurementId: '', // Leave this empty if you're not using Firebase Analytics
  ),
  );
  runApp(MaterialApp(
    home:  HomePage(),
  ));
}

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Devisree",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: const Color(0xFF001F3F),
        ),
        body: Container(
          color: Colors.grey[200], // Light gray background
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildContainer(
                      context,
                      Icons.notes,
                      "To do List",
                      const ToDoPage(),
                      "Custom Action on ToDoListPage",
                    ),
                    _buildContainer(
                      context,
                      Icons.bookmarks,
                      "Documents",
                      const DocumentsPage(),
                      "Custom Action on DocumentsPage",
                    ),

                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildContainer(
                      context,
                      Icons.person,
                      "Personal",
                      const PersonalPage(),
                      "Custom Action on PersonalPage",
                    ),
                    _buildContainer(
                      context,
                      Icons.note,
                      "Notepad", // New box for Notepad
                      const Notepad(), // Replace with your NotepadApp widget
                      "Custom Action on NotepadPage",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPageWithAction(BuildContext context, Widget page, String customAction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    ).then((result) {
      // Perform custom action when returning from the new page
      // print(customAction);
    });
  }

  Widget _buildContainer(BuildContext context, IconData icon, String text, Widget destinationPage, String customAction) {
    return GestureDetector(
      onTap: () {
        // Navigate to the destination page
        _navigateToPageWithAction(context, destinationPage, customAction);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFA700),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        width: 150.0,
        height: 150.0,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: Colors.white), // Placeholder icon
            const SizedBox(height: 10.0),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
