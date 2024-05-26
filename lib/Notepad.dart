import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  runApp(NotepadApp());
}

class NotepadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notepad',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Notepad(),
    );
  }
}

class Note {
  String title;
  String content;
  Color color;

  Note({required this.title, required this.content, required this.color});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
      color: Color(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'color': color.value,
    };
  }
}

class Notepad extends StatefulWidget {
  const Notepad({Key? key}) : super(key: key);

  @override
  _NotepadState createState() => _NotepadState();
}

class _NotepadState extends State<Notepad> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJson = prefs.getStringList('notes') ?? [];

    notes = notesJson.map((jsonString) => Note.fromJson(json.decode(jsonString))).toList();

    setState(() {});
  }

  void _addNote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJson = prefs.getStringList('notes') ?? [];

    Note newNote = Note(
      title: 'Note ${notes.length + 1}',
      content: '',
      color: Colors.accents[Random().nextInt(Colors.accents.length)],
    );

    notes.add(newNote);
    notesJson.add(json.encode(newNote.toJson()));

    await prefs.setStringList('notes', notesJson);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notepad'),
        actions: [
          IconButton(
            onPressed: () {
              _addNote();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: notes.length,
        separatorBuilder: (context, index) => Divider(height: 20),
        itemBuilder: (context, index) {
          return Container(
            color: notes[index].color,
            child: ListTile(
              title: Text(notes[index].title),
              onTap: () async {
                Note? updatedNote = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(note: notes[index]),
                  ),
                );
                if (updatedNote != null) {
                  setState(() {
                    notes[index] = updatedNote;
                    SharedPreferences.getInstance().then((prefs) {
                      List<String> notesJson = notes.map((note) => json.encode(note.toJson())).toList();
                      prefs.setStringList('notes', notesJson);
                    });
                  });
                }
              },
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    notes.removeAt(index);
                    SharedPreferences.getInstance().then((prefs) {
                      List<String> notesJson = notes.map((note) => json.encode(note.toJson())).toList();
                      prefs.setStringList('notes', notesJson);
                    });
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _contentController;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note.content);
    _titleController = TextEditingController(text: widget.note.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Enter title...',
          ),
          onChanged: (value) {
            widget.note.title = value; // Update the note's title
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              _saveChanges();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(25.0),
        child: TextField(
          controller: _contentController,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Start typing your note...',
          ),
          onChanged: (value) {
            widget.note.content = value; // Update the note's content
          },
        ),
      ),
    );
  }

  void _saveChanges() {
    Navigator.pop(context, widget.note);
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
