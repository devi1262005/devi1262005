import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late TextEditingController _passwordController;
  String? _setPassword;
  List<String> _documents = []; // Initialize _documents as an empty list

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(_documents[index]),
                    onTap: () {
                      _showAccessPasswordDialog(_documents[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_setPassword != null) {
            _uploadDocument();
          } else {
            _setPasswordDialog();
          }
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _setPasswordDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Enter Password',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _setPassword = _passwordController.text;
                  _passwordController.clear(); // Clear the password field
                });
                Navigator.of(context).pop();
                _uploadDocument(); // Upload document after setting password
              },
              child: const Text('Set Password'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String fileName = result.files.first.name;
      setState(() {
        _documents.add(fileName);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document $fileName uploaded successfully!'),
        ),
      );
    }
  }

  Future<void> _showAccessPasswordDialog(String document) async {
    bool _isCorrectPassword = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Access Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter Password',
                ),
                onChanged: (value) {
                  setState(() {
                    _isCorrectPassword = value == _setPassword;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_isCorrectPassword) {
                    Navigator.of(context).pop();
                    _openDocument(document);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Incorrect password!'),
                      ),
                    );
                  }
                },
                child: const Text('Access'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDocument(String document) async {
    final baseUrl = 'https://example.com/documents/'; // Replace 'example.com' with your domain
    final url = Uri.parse('$baseUrl$document.pdf');
    if (await launcher.canLaunchUrl(url)) {
      await launcher.launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open document: $document'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(const MaterialApp(
    home: DocumentsPage(),
  ));
}
