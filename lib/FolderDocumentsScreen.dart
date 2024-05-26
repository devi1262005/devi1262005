import 'package:flutter/material.dart';

class FolderDocumentsScreen extends StatelessWidget {
  final List<String> documents;

  const FolderDocumentsScreen({Key? key, required this.documents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folder Documents'),
      ),
      body: ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(documents[index]),
          );
        },
      ),
    );
  }
}
