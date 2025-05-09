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
      stompClient.subscribe(
        destination: '/topic/user/$_myId',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            final parsedData = jsonDecode(frame.body!) as Map<String, dynamic>;
            log('📩 Received: $parsedData');

            // 필요한 핸들러에 전달
            _onMessage?.call(parsedData);
          }
        },
      );
    }
  }

  // 콜백 설정용
  Function(Map<String, dynamic>)? _onMessage;
  void setMessageHandler(Function(Map<String, dynamic>) handler) {
    _onMessage = handler;
  }

  void disconnect() {
    stompClient.deactivate();
  }

  bool get isConnected => stompClient.connected;
}
