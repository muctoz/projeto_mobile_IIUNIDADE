import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Note {
  String? documentId;
  String title;
  String content;

  Note({required this.title, required this.content, required this.documentId});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'documentId': documentId,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
        title: map['title'],
        content: map['content'],
        documentId: map['documentId']);
  }

  static List<Map<String, dynamic>> noteListToMapList(List<Note> notes) {
    return notes.map((note) => note.toMap()).toList();
  }

  static List<Note> noteListFromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => Note.fromMap(map)).toList();
  }
}

class NotePage extends StatefulWidget {
  final List<Note> notes;

  NotePage({Key? key, this.notes = const []}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Note> _notes = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notes = widget.notes;
    _loadNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    setState(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final notesWithoutPassword = userProvider.notesWithoutPassword;
      print(notesWithoutPassword);

      _notes = Note.noteListFromMapList(notesWithoutPassword);
    });
  }

  void _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesMapList = Note.noteListToMapList(_notes);
    final notesJson = jsonEncode(notesMapList);
    // await prefs.setString('notesWithoutPassword', notesJson);
  }

  void _addNote() async {
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      UserCredential? userCredential = userProvider.userCredential;

      if (userCredential != null && userCredential.user != null) {
        final newNote = {
          'title': _titleController.text,
          'content': _contentController.text,
        };

        final docRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .collection('NotasSemSenha')
            .doc();

        final noteId = docRef.id; // Limitando o tamanho do ID gerado

        newNote['documentId'] = noteId; // Adicionando o campo documentId à nota

        await docRef.set(newNote, SetOptions(merge: true));

        userProvider.addNoteWithoutPassword(newNote);

        _titleController.clear();
        _contentController.clear();
        setState(() {});
      } else {
        print('Usuário não autenticado.');
        print(userCredential!.user!);
      }
    } catch (error) {
      print('Erro ao adicionar nota: $error');
    }
  }

  void _updateNote(int index) async {
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      UserCredential? userCredential = userProvider.userCredential;

      if (userCredential != null && userCredential.user != null) {
        final user = FirebaseAuth.instance.currentUser;
        final note = _notes[index];

        final updatedNote = {
          'documentId': note.documentId,
          'title': _titleController.text,
          'content': _contentController.text,
        };

        final docRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .collection('NotasSemSenha')
            .doc(note.documentId);

        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          await docRef.update(updatedNote);

          setState(() {
            note.title = _titleController.text;
            note.content = _contentController.text;
            _titleController.clear();
            _contentController.clear();
          });

          userProvider.updateNoteWithoutPassword(note.documentId, updatedNote);
          // _saveNotes();
        } else {
          print('O documento não existe.');
        }
      } else {
        print('Usuário não autenticado.');
        print(userCredential!.user!);
      }
    } catch (error) {
      print('Erro ao atualizar nota: $error');
    }
  }

  void _deleteNote(int index) async {
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      UserCredential? userCredential = userProvider.userCredential;

      if (userCredential != null && userCredential.user != null) {
        final user = FirebaseAuth.instance.currentUser;
        final note = _notes[index];

        final docRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .collection('NotasSemSenha')
            .doc(note.documentId);

        final docSnapshot = await docRef.get();
        print(docSnapshot);
        print(docRef);

        if (docSnapshot.exists) {
          await docRef.delete();

          setState(() {
            _notes.removeAt(index);
          });

          userProvider.removeNoteWithoutPassword(note.documentId);
          // _saveNotes();
        } else {
          print('O documento não existe.');
        }
      } else {
        print('Usuário não autenticado.');
        print(userCredential!.user!);
      }
    } catch (error) {
      print('Erro ao excluir nota: $error');
    }
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
        title: Text('Notas'),
        backgroundColor: Color(0xFF011E36),
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
              color: Color(0xFFFF0000),
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
        onPressed: _showNoteDialog,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF011E36),
      ),
    );
  }
}
