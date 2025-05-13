import 'dart:developer';

import 'package:chat_application/apis/noteApi.dart';
import 'package:chat_application/model/model_note.dart';
import 'package:chat_application/src/data/keyData.dart';
import 'package:flutter/material.dart';

class NoteProvider extends ChangeNotifier {
  int? myId;

  final List<Note> _notes = List.empty(growable: true);
  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    myId ??= await SharedPreferencesHelper.getMyId();
    try {
      final response = await fetchNoteList(myId!);
      _notes.clear();
      _notes.addAll(response);
      notifyListeners();
    } catch (e) {
      log('Error loading chat rooms: $e');
    }
  }

  Future<void> readNotes(int noteId, int index) async {
    await readNote(myId!, noteId);
    _notes[index] = _notes[index].copyWith(isRead: true);
    notifyListeners();
  }

  Future<void> deleteNotes(int noteId, int index) async {
    await deleteNoteRecord(noteId, myId!);
    _notes.removeAt(index);
    notifyListeners();
  }

  void handleSocketMessage(Map<String, dynamic> message) {
    if (message['type'] == 'NOTE') {
      _notes.add(Note(
        noteId: message['message']['noteId'],
        aptId: message['message']['aptId'],
        aptName: message['message']['aptName'],
        phoneNumber: message['message']['phoneNumber'],
        noteText: message['message']['noteText'],
        regDate: DateTime.parse(
            message['message']['regDate'] ?? DateTime.now().toIso8601String()),
        isRead: false,
      ));

      _notes.sort((a, b) => b.regDate.compareTo(a.regDate));
      notifyListeners();
    }
  }
}
