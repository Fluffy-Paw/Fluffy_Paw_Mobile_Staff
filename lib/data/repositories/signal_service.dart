// signalr_service.dart

import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class SignalRService {
  final Ref ref;
  HubConnection? _hubConnection;
  bool _isConnecting = false;
  Timer? _reconnectTimer;
  final _messageHandlers = <String, List<Function(List<dynamic>?)>>{};
  
  SignalRService(this.ref);

  Future<String?> _getAuthToken() async {
    try {
      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token == null) throw Exception('Authentication token not found');
      return token;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  Future<void> connect() async {
    // Cancel any existing reconnection attempts
    _reconnectTimer?.cancel();
    
    if (_hubConnection?.state == HubConnectionState.connected) {
      print('SignalR: Already connected');
      return;
    }

    if (_isConnecting) {
      print('SignalR: Connection attempt in progress');
      return;
    }

    try {
      _isConnecting = true;
      final token = await _getAuthToken();
      if (token == null) {
        _isConnecting = false;
        return;
      }

      // Dispose existing connection if any
      await _hubConnection?.stop();
      _hubConnection = null;

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            'https://fluffypaw.azurewebsites.net/NotificationHub',
            HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.webSockets,
              skipNegotiation: true,
              logging: (level, message) => print('SignalR Log: $message'),
            ))
          .withAutomaticReconnect([0, 2000, 10000, 30000])
          .build();

      _setupConnectionHandlers();

      await _hubConnection?.start();
      _isConnecting = false;
      print('SignalR: Connected successfully');
      
      // Resubscribe handlers after successful connection
      _messageHandlers.forEach((event, handlers) {
        handlers.forEach((handler) {
          _hubConnection?.on(event, handler);
        });
      });
    } catch (e) {
      print('SignalR Error: $e');
      _isConnecting = false;
      _hubConnection = null;
      
      // Schedule reconnection attempt
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        connect();
      });
    }
  }

  void _setupConnectionHandlers() {
    _hubConnection?.onclose((error) {
      print('SignalR: Connection closed, error: $error');
      if (!_isConnecting && _hubConnection?.state != HubConnectionState.connected) {
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(seconds: 5), () {
          connect();
        });
      }
    });
  }

  void addHandler(String event, Function(List<dynamic>?) handler) {
    if (!_messageHandlers.containsKey(event)) {
      _messageHandlers[event] = [];
    }
    if (!_messageHandlers[event]!.contains(handler)) {
      _messageHandlers[event]!.add(handler);
      if (_hubConnection?.state == HubConnectionState.connected) {
        _hubConnection?.on(event, handler);
      }
    }
  }

  void removeHandler(String event, Function(List<dynamic>?) handler) {
    _messageHandlers[event]?.remove(handler);
    if (_hubConnection?.state == HubConnectionState.connected) {
      _hubConnection?.off(event, method: handler);
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _messageHandlers.clear();
    _hubConnection?.stop();
    _hubConnection = null;
    _isConnecting = false;
  }

  HubConnectionState? get connectionState => _hubConnection?.state;
}

final signalRServiceProvider = Provider<SignalRService>((ref) => SignalRService(ref));