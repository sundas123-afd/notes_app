import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/firestore_service.dart';


class NotesProvider with ChangeNotifier {

  List<Note> notesList = [];
  
  // Firestore service
  FirestoreService firestoreService = FirestoreService();
  
  // Loading state
  bool isLoading = false;
  
  // Current user ID
  String? userId;

  
  void setUserId(String id) {
    userId = id;
  }

  
  Future<void> loadNotes() async {
    if (userId == null) return;
    
    isLoading = true;
    notifyListeners();
    
    
    notesList = await firestoreService.loadNotes(userId!);
    
    isLoading = false;
    notifyListeners();
  }

  
  Future<bool> addNote(String title, String content) async {
    if (userId == null) return false;
    
    
    Note newNote = Note(
      id: Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
   
    bool success = await firestoreService.addNote(userId!, newNote);
    
    if (success) {
      
      notesList.insert(0, newNote);
      notifyListeners();
    }
    
    return success;
  }

 
  Future<bool> updateNote(String id, String title, String content) async {
    if (userId == null) return false;
    
   
    int index = -1;
    for (int i = 0; i < notesList.length; i++) {
      if (notesList[i].id == id) {
        index = i;
        break;
      }
    }
    
    if (index == -1) return false;
    
    
    notesList[index].title = title;
    notesList[index].content = content;
    notesList[index].updatedAt = DateTime.now();
    
    
    bool success = await firestoreService.updateNote(userId!, notesList[index]);
    
    if (success) {
      
      Note updatedNote = notesList[index];
      notesList.removeAt(index);
      notesList.insert(0, updatedNote);
      notifyListeners();
    }
    
    return success;
  }

  
  Future<bool> deleteNote(String id) async {
    if (userId == null) return false;
    
    
    bool success = await firestoreService.deleteNote(userId!, id);
    
    if (success) {
      
      notesList.removeWhere((note) => note.id == id);
      notifyListeners();
    }
    
    return success;
  }

 
  List<Note> searchNotes(String query) {
    if (query.isEmpty) {
      return notesList;
    }
    
    String searchQuery = query.toLowerCase();
    
    List<Note> searchResults = [];
    for (Note note in notesList) {
      if (note.title.toLowerCase().contains(searchQuery) ||
          note.content.toLowerCase().contains(searchQuery)) {
        searchResults.add(note);
      }
    }
    
    return searchResults;
  }

  
  void clearNotes() {
    notesList = [];
    userId = null;
    notifyListeners();
  }
}