// lib/services/websocket_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  late StompClient stompClient;
  int? _myId;

  WebSocketService._internal();

  final Map<String, StompUnsubscribe> _subscriptions = {};

  void connect(int myId) {
    _myId = myId;
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/ws-stomp',
        onConnect: _onConnect,
        onWebSocketError: (error) => log('WebSocket Error: $error'),
        onDisconnect: (_) => log('WebSocket Disconnected'),
      ),
    );
    stompClient.activate();
  }

  void _onConnect(StompFrame frame) {
    log('WebSocket Connected');
    if (_myId != null) {
      final dest = '/topic/user/$_myId';
      if (!_subscriptions.containsKey(dest)) {
        final sub = stompClient.subscribe(
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

  // 채팅방 구독 경로 추가 로직
  void subscribeToChatRoom(int roomId, int myId) {
    final subscriptionId = 'chatroom-$roomId';
    final dest = '/topic/chatroom/$roomId';
    if (!_subscriptions.containsKey(dest)) {
      log("채팅방 입장시 구독 경로 연결!! $roomId");
      final sub = stompClient.subscribe(
        destination: dest,
        headers: {
          'id': subscriptionId,
          'myId': myId.toString(), // 서버에서 읽을 수 있도록 추가
        },
        callback: (StompFrame frame) {
          if (frame.body != null) {
            final parsedData = jsonDecode(frame.body!) as Map<String, dynamic>;
            log('📩 Received [chatRoom]: $parsedData');
            // 필요한 핸들러에 전달
            _onMessage?.call(parsedData);
          }
        },
      );
      _subscriptions[subscriptionId] = sub;
    }
  }

  /// 채팅방 구독 취소
  void unsubscribeFromChatRoom(int roomId) {
    log("채팅방 퇴장시 구독 경로 취소!! $roomId");
    final subscriptionId = 'chatroom-$roomId';
    if (_subscriptions.containsKey(subscriptionId)) {
      _subscriptions[subscriptionId]!(); // 구독 취소
      _subscriptions.remove(subscriptionId);
      log('❌ Unsubscribed from chatroom $roomId');
    }
  }

  // 콜백 설정용
  Function(Map<String, dynamic>)? _onMessage;
  void setMessageHandler(Function(Map<String, dynamic>) handler) {
    _onMessage = handler;
  }

  void sendMessage(Map<String, Object> messageData) async {
    stompClient.send(
      destination: '/app/message',
      body: jsonEncode(messageData),
    );
  }

  void disconnect() {
    // 모든 구독 취소
    for (var unsub in _subscriptions.values) {
      unsub();
    }
    _subscriptions.clear();
    stompClient.deactivate();
  }

  bool get isConnected => stompClient.connected;
}
