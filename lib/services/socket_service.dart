import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_endpoints.dart';

class SocketService {
  static IO.Socket? _socket;

  static IO.Socket get socket {
    if (_socket == null) {
      _init();
    }
    return _socket!;
  }

  static void _init() {
    _socket = IO.io(
      ApiEndpoints.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('Socket.io bağlandı');
    });

    _socket!.onDisconnect((_) {
      print('Socket.io bağlantısı kesildi');
    });
  }

  static void connect() {
    if (!socket.connected) {
      socket.connect();
    }
  }

  static void joinLiveRoom(int roomId, Map<String, dynamic> user) {
    connect();
    socket.emit('join_live_room', {
      'room_id': roomId,
      'user': user,
    });
  }

  static void sendChatMessage(int roomId, Map<String, dynamic> user, String message) {
    socket.emit('send_chat', {
      'room_id': roomId,
      'user': user,
      'message': message,
    });
  }

  static void sendLikeHeart(int roomId) {
    socket.emit('send_like_heart', {
      'room_id': roomId,
      'color': '#FE2C55',
    });
  }

  static void leaveLiveRoom(int roomId) {
    socket.emit('leave_live_room', {'room_id': roomId});
  }

  static void disconnect() {
    _socket?.disconnect();
  }
}
