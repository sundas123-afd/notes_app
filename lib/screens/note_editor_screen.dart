import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  
  final Note? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  
  late TextEditingController titleController;
  late TextEditingController contentController;
  
  
  bool isModified = false;

  @override
  void initState() {
    super.initState();
    
   
    titleController = TextEditingController(
      text: widget.existingNote?.title ?? '',
    );
    contentController = TextEditingController(
      text: widget.existingNote?.content ?? '',
    );
    
    
    titleController.addListener(onTextChanged);
    contentController.addListener(onTextChanged);
  }

 
  void onTextChanged() {
    if (!isModified) {
      setState(() {
        isModified = true;
      });
    }
  }

  @override
  void dispose() {
   
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  
  Future<void> saveNote() async {
    String title = titleController.text.trim();
    String content = contentController.text.trim();

   
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    NotesProvider notesProvider = Provider.of<NotesProvider>(context, listen: false);

   
    if (widget.existingNote == null) {
      await notesProvider.addNote(title, content);
    } 
    
    else {
      await notesProvider.updateNote(widget.existingNote!.id, title, content);
    }

   
    Navigator.pop(context);
    
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingNote == null ? 'Note created' : 'Note updated',
        ),
      ),
    );
  }

 
  Future<bool> onBackPressed() async {
    
    if (isModified) {
      
      bool? shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Save changes?'),
          content: Text('Do you want to save your changes?'),
          actions: [
            // Discard button
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Discard'),
            ),
            // Save button
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Save'),
            ),
          ],
        ),
      );

      
      if (shouldSave == true) {
        await saveNote();
        return false;
      }
      
      return shouldSave ?? false;
    }
    
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        // Top bar
        appBar: AppBar(
          title: Text(widget.existingNote == null ? 'New Note' : 'Edit Note'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          actions: [
            // Save button
            IconButton(
              icon: Icon(Icons.check),
              onPressed: saveNote,
            ),
          ],
        ),
        
        // Editor
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title input
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 24),
                ),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
              
              Divider(),
              
              // Content input
              Expanded(
                child: TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: 'Start writing...',
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 16),
                  maxLines: null, // Unlimited lines
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}