import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class Note {
  String title;
  String content;

  Note({
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      content: map['content'],
    );
  }
}

class NotePageProtect extends StatefulWidget {
  const NotePageProtect({Key? key}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePageProtect> {
  List<Note> _notes = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('notesprotected');
    if (notesJson != null) {
      setState(() {
        _notes = notesJson
            .map((noteJson) => Note.fromMap(jsonDecode(noteJson)))
            .toList();
      });
    }
  }

  void _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = _notes.map((note) => jsonEncode(note.toMap())).toList();
    await prefs.setStringList('notesprotected', notesJson);
  }

  void _addNote() {
    setState(() {
      final title = _titleController.text;
      final content = _contentController.text;
      _notes.add(Note(
        title: title,
        content: content,
      ));
      _titleController.clear();
      _contentController.clear();
      _saveNotes();
    });
  }

  void _updateNote(int index) {
    setState(() {
      final title = _titleController.text;
      final content = _contentController.text;
      _notes[index] = Note(
        title: title,
        content: content,
      );
      _titleController.clear();
      _contentController.clear();
      _saveNotes();
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      _saveNotes();
    });
  }

  void _showNoteDialog({Note? note}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Nova Nota' : 'Editar Nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController..text = note?.title ?? '',
              decoration: InputDecoration(
                labelText: 'Título',
              ),
            ),
            TextField(
              controller: _contentController..text = note?.content ?? '',
              decoration: InputDecoration(
                labelText: 'Conteúdo',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (note == null) {
                _addNote();
              } else {
                _updateNote(_notes.indexOf(note));
              }
              Navigator.pop(context);
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas Protected'),
      ),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () => _showNoteDialog(note: note),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirmar exclusão'),
                  content: Text('Tem certeza que deseja excluir esta nota?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteNote(index);
                      },
                      child: Text('Excluir'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
