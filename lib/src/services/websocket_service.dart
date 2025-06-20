// lib/services/websocket_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:chat_application/model/model_sendMsg.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  StompClient? stompClient;
  int? _myId;

  WebSocketService._internal();

  final Map<String, StompUnsubscribe> _subscriptions = {};

  void connect(int myId) {
    _myId = myId;
    if (stompClient != null && stompClient!.connected) {
      log('이전 웹소켓 연결 해제 중...');
      stompClient!.deactivate();
      stompClient = null; // 클린하게 초기화
    }

    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/ws-stomp',
        onConnect: _onConnect,
        onWebSocketError: (error) => log('WebSocket Error: $error'),
        onDisconnect: (_) => log('WebSocket Disconnected'),
      ),
    );
    stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    log('WebSocket Connected');
    if (_myId != null) {
      final dest = '/topic/chat/$_myId';
      if (!_subscriptions.containsKey(dest)) {
        final sub = stompClient!.subscribe(
          destination: dest,
          callback: (StompFrame frame) {
            if (frame.body != null) {
              final parsedData =
                  jsonDecode(frame.body!) as Map<String, dynamic>;
              log('📩 Received [user]: $parsedData');
              // 필요한 핸들러에 전달
              _onMessage?.call(parsedData);
            }
          },
        );
        _subscriptions[dest] = sub;
      }
    }
  }

  // 콜백 설정용
  Function(Map<String, dynamic>)? _onMessage;
  void setMessageHandler(Function(Map<String, dynamic>) handler) {
    _onMessage = handler;
  }

  void sendMessage(SendMessage messageData) async {
    stompClient!.send(
      destination: '/app/message',
      body: jsonEncode(messageData),
    );
  }

  void submitChatToIncome(int userId, int roomId) async {
    // log("채팅방 입장 redis로 정보 전달!");
    // log("userId: $userId (${userId.runtimeType}), roomId: $roomId (${roomId.runtimeType})");

    stompClient!.send(
      destination: '/app/chat/income',
      body: jsonEncode({
        'roomId': roomId,
        'userId': userId,
      }),
    );
  }

  void submitChatToLeave(int userId, int roomId) async {
    log("채팅방 퇴장 redis로 정보 전달!");
    stompClient!.send(
      destination: '/app/chat/leave',
      body: jsonEncode({
        'roomId': roomId,
        'userId': userId,
      }),
    );
  }

  void disconnect() {
    // 모든 구독 취소
    for (var unsub in _subscriptions.values) {
      unsub();
    }
    _subscriptions.clear();
    stompClient!.deactivate();
  }

  bool get isConnected => stompClient!.connected;
}
