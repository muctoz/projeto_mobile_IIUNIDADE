import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  UserCredential? _userCredential;
  List<Map<String, dynamic>> _notesWithPassword = [];
  List<Map<String, dynamic>> _notesWithoutPassword = [];

  User? get user => _user;
  UserCredential? get userCredential => _userCredential;
  List<Map<String, dynamic>> get notesWithPassword => _notesWithPassword;
  List<Map<String, dynamic>> get notesWithoutPassword => _notesWithoutPassword;

  void setUserCredential(UserCredential userCredential) {
    _userCredential = userCredential;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void setNotesWithPassword(List<Map<String, dynamic>> notes) {
    _notesWithPassword = notes;
    notifyListeners();
  }

  void setNotesWithoutPassword(List<Map<String, dynamic>> notes) {
    _notesWithoutPassword = notes;
    notifyListeners();
  }

  void addNoteWithoutPassword(Map<String, dynamic> note) {
    _notesWithoutPassword.add(note);
    notifyListeners();
  }

  void updateNoteWithoutPassword(String? documentId, Map<String, dynamic> updatedNote) {
    final index = _notesWithoutPassword.indexWhere((note) => note['documentId'] == documentId);
    if (index != -1) {
      _notesWithoutPassword[index] = updatedNote;
      notifyListeners();
    }
  }

  void removeNoteWithoutPassword(String? documentId) {
    _notesWithoutPassword.removeWhere((note) => note['documentId'] == documentId);
    notifyListeners();
  }
}