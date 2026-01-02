import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';


class FirestoreService {
  
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Note>> loadNotes(String userId) async {
  try {
    QuerySnapshot snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('updatedAt', descending: true)
        .get();

    List<Note> notes = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      notes.add(
        Note.fromMap({
          ...data,
          'id': doc.id,
        }),
      );
    }

    return notes; // ✅ success return
  } catch (e) {
    print('Error loading notes: $e');
    return []; // ✅ error return
  }
}


  
  Future<bool> addNote(String userId, Note note) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(note.id)
          .set(note.toMap());
      
      return true; // Success
    } catch (e) {
      print('Error adding note: $e');
      return false;
    }
  }

  
  Future<bool> updateNote(String userId, Note note) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(note.id)
          .update(note.toMap());
      
      return true; // Success
    } catch (e) {
      print('Error updating note: $e');
      return false;
    }
  }

 
  Future<bool> deleteNote(String userId, String noteId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .delete();
      
      return true; 
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    }
  }

  
  Stream<List<Note>> getNotesStream(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      List<Note> notes = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        notes.add(Note.fromMap(data));
      }
      return notes;
    });
  }
}
 

