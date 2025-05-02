import 'dart:convert';
import 'dart:developer';

import 'package:chat_application/apis/noteApi.dart';
import 'package:chat_application/model/model_note.dart';
import 'package:chat_application/src/component/noteDialog.dart';
import 'package:flutter/material.dart';
import 'package:chat_application/size_config.dart';
import 'package:go_router/go_router.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../data/keyData.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  int? myId;
  String? myName;
  Future<void> _loadMyIdAndMyName() async {
    myId = await SharedPreferencesHelper.getMyId();
    myName = await SharedPreferencesHelper.getMyName();
  }

  late List<Note> _notes = [];
  Future<void> _loadNotes() async {
    try {
      List<Note> noteList = await fetchNoteList(myId!);
      setState(() {
        _notes = noteList;
      });
    } catch (e) {
      log('노트 불러오기 실패: $e');
    }
  }

  Future<void> _readNotes(int noteId, int index) async {
    try {
      await readNote(myId!, noteId);
      setState(() {
        _notes[index] = _notes[index].copyWith(isRead: true);
      });
    } catch (e) {
      log('노트 불러오기 실패: $e');
    }
  }

  Future<void> _deleteNotes(int noteId, int index) async {
    try {
      await deleteNoteRecord(noteId, myId!);
      setState(() {
        _notes.removeAt(index);
      });
    } catch (e) {
      log('노트 불러오기 실패: $e');
    }
  }

  late StompClient stompClient;
  void connect() {
    stompClient = StompClient(
      config: StompConfig(
        // url: 'ws://localhost:8080/ws-stomp',
        url: 'ws://10.0.2.2:8080/ws-stomp',
        onConnect: (StompFrame frame) {
          log('Connected to WebSocket');
          if (myId != null) {
            // 메시지 구독
            stompClient.subscribe(
              destination: '/topic/user/$myId',
              callback: (StompFrame frame) {
                if (frame.body != null) {
                  final parsedData =
                      jsonDecode(frame.body!) as Map<String, dynamic>;
                  log("새로운 쪽지 목록 업데이트 데이터: $parsedData");
                  if (parsedData['type'] == 'NOTE') {
                    setState(() {
                      // 새로운 쪽지 추가
                      _notes.add(Note(
                        noteId: parsedData['message']['noteId'],
                        aptId: parsedData['message']['aptId'],
                        aptName: parsedData['message']['aptName'],
                        phoneNumber: parsedData['message']['phoneNumber'],
                        noteText: parsedData['message']['noteText'],
                        regDate: DateTime.parse(parsedData['message']
                                ['regDate'] ??
                            DateTime.now().toIso8601String()),
                        isRead: false,
                      ));

                      _notes = List.from(_notes)
                        ..sort((a, b) => b.regDate.compareTo(a.regDate));
                    });
                  }
                }
              },
            );
          }
        },
        onWebSocketError: (dynamic error) => log('WebSocket Error: $error'),
        onDisconnect: (StompFrame frame) => log('Disconnected'),
      ),
    );

    // WebSocket 연결 시작
    stompClient.activate();
  }

  @override
  void initState() {
    super.initState();
    _loadMyIdAndMyName();
    connect();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNotes();
  }

  void disconnect() {
    if (stompClient.connected) {
      stompClient.deactivate();
    }
  }

  @override
  void dispose() {
    super.dispose();
    disconnect();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    // ui 구성
    return Scaffold(
      // 기본적인 앱 레이아웃
      appBar: AppBar(
        // 상단 바
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('매물 문의 보관함'),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: _notes.length,
            itemBuilder: (context, index) {
              final note = _notes[index];
              return GestureDetector(
                onTap: () {
                  note.isRead ? () : _readNotes(note.noteId, index); // 쪽지 읽음처리
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(note.aptName),
                      content: NoteDialog(
                        noteId: note.noteId,
                        aptId: note.aptId,
                        aptName: note.aptName,
                        phoneNumber: note.phoneNumber,
                        noteText: note.noteText,
                        regDate: note.regDate,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('닫기'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey, // 선 색상
                      width: 0.5, // 선 두께
                    ),
                  ),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            note.aptName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            note.noteText.length > 8
                                ? '${note.noteText.substring(0, 8)}...'
                                : note.noteText,
                          )
                        ],
                      ),
                      note.isRead
                          ? const SizedBox.shrink()
                          : Padding(
                              padding:
                                  const EdgeInsets.only(right: 16), // 오른쪽 여백 추가
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color:
                                      Color.fromARGB(255, 255, 47, 47), // 빨간색
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () {
                          _deleteNotes(note.noteId, index);
                        },
                      ),
                    ],
                  )),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
