import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
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
  runApp(const MaterialApp(
    home:  PersonalPage(),
  ));
}



class PersonalPage extends StatefulWidget {
  const PersonalPage({Key? key}) : super(key: key);

  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('personal');

  List<Folder> folders = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirebase();
    _database.onChildAdded.listen((event) {
      setState(() {
        folders.add(Folder.fromJson(event.snapshot.value as Map<dynamic, dynamic>));
      });
    });

    _database.onChildRemoved.listen((event) {
      setState(() {
        folders.removeWhere((folder) => folder.key == event.snapshot.key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              for (var folder in folders)
                FolderItem(
                  key: ValueKey(folder.key),
                  folder: folder,
                  onDeleteFolder: () {
                    deleteFolder(folder.key);
                  },
                  onChangeIcon: (newIcon) {
                    updateIcon(folder.key, newIcon);
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addFolder(Folder(
            key: '',
            folderName: 'Folder ${folders.length + 1}',
            documents: [],
            icon: Icons.folder,
            iconUrl: 'https://example.com/icon.png',
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void addFolder(Folder folder) {
    _database.push().set(folder.toJson());
  }

  void deleteFolder(String folderId) {
    _database.child(folderId).remove();
  }

  void updateIcon(String folderId, IconData newIcon) {
    _database.child(folderId).update({'iconUrl': 'https://example.com/new_icon.png'});
  }

  void _fetchDataFromFirebase() {
    DatabaseReference reference = FirebaseDatabase.instance.ref().child('personal');
    reference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        folders.add(Folder.fromJson({...value, 'key': key}));
      });
      setState(() {});
    } as FutureOr Function(DatabaseEvent value)).catchError((error) {
    });
  }
}

class FolderItem extends StatelessWidget {
  final Folder folder;
  final VoidCallback onDeleteFolder;
  final Function(IconData) onChangeIcon;

  const FolderItem({
    Key? key,
    required this.folder,
    required this.onDeleteFolder,
    required this.onChangeIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showOptionsDialog(context);
      },
      child: Column(
        children: [
          IconButton(
            icon: Icon(folder.icon, size: 50),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FolderPage(
                    folder: folder,
                  ),
                ),
              );
            },
          ),
          Text(
            folder.folderName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Folder Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Change Icon'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showIconPicker(context);
                },
              ),
              ListTile(
                title: const Text('Delete Folder'),
                onTap: onDeleteFolder,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showIconPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Icon'),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(
                Folder.iconList.length,
                    (index) => ListTile(
                  leading: Icon(Folder.iconList[index]),
                  title: Text('Icon ${index + 1}'),
                  onTap: () {
                    onChangeIcon(Folder.iconList[index]);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FolderPage extends StatelessWidget {
  final Folder folder;

  const FolderPage({
    required this.folder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folder.folderName),
      ),
      body: folder.documents.isEmpty
          ? const Center(child: Text('No files here'))
          : ListView.builder(
        itemCount: folder.documents.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(folder.documents[index]),
            onTap: () {
              _openFile(folder.documents[index]);
            },
            onLongPress: () {
              _showDeleteDocumentDialog(context, folder.documents[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addFilesToFolder(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addFilesToFolder(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
  }

  void _openFile(String fileName) {
    // Implement file opening logic here
  }

  void _showDeleteDocumentDialog(BuildContext context, String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text('Are you sure you want to delete $fileName from ${folder.folderName}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete document from Firebase
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class Folder {
  static final List<IconData> iconList = [
    Icons.folder,
    Icons.access_alarm,
    Icons.accessibility,
    Icons.account_balance,
    Icons.add,
    // Add more icons as needed
  ];

  String key;
  String folderName;
  List<String> documents;
  IconData icon;
  String iconUrl;

  Folder({
    required this.key,
    required this.folderName,
    required this.documents,
    required this.icon,
    required this.iconUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'folderName': folderName,
      'documents': documents,
      'icon': icon.codePoint,
      'iconUrl': iconUrl,
    };
  }

  factory Folder.fromJson(Map<dynamic, dynamic> json) {
    return Folder(
      key: json['key'] ?? '',
      folderName: json['folderName'] ?? '',
      documents: List<String>.from(json['documents'] ?? []),
      icon: IconData(json['icon'] ?? Icons.folder.codePoint, fontFamily: 'MaterialIcons'),
      iconUrl: json['iconUrl'] ?? '',
    );
  }
}
