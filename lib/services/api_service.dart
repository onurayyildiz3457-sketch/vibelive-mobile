import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/video_model.dart';
import '../models/live_room_model.dart';
import '../models/gift_model.dart';

class ApiService {
  // Video Akışını Getir
  static Future<List<VideoModel>> getFeed({int userId = 1}) async {
    try {
      final res = await http.get(Uri.parse('${ApiEndpoints.feed}?user_id=$userId'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['feed'] ?? [];
        return list.map((item) => VideoModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('Feed getirme hatası: $e');
    }
    return [];
  }

  // Beğeni Aç / Kapat
  static Future<bool?> toggleLike(int videoId, int userId) async {
    try {
      final res = await http.post(
        Uri.parse(ApiEndpoints.likeVideo(videoId)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['liked'] as bool;
      }
    } catch (e) {
      print('Like hatası: $e');
    }
    return null;
  }

  // Yorumları Listele
  static Future<List<dynamic>> getComments(int videoId) async {
    try {
      final res = await http.get(Uri.parse(ApiEndpoints.comments(videoId)));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['comments'] ?? [];
      }
    } catch (e) {
      print('Yorum hatası: $e');
    }
    return [];
  }

  // Yorum Gönder
  static Future<bool> postComment(int videoId, int userId, String text) async {
    try {
      final res = await http.post(
        Uri.parse(ApiEndpoints.comments(videoId)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'text': text}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Aktif Canlı Yayınları Listele
  static Future<List<LiveRoomModel>> getActiveLiveRooms() async {
    try {
      final res = await http.get(Uri.parse(ApiEndpoints.activeLiveRooms));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['live_rooms'] ?? [];
        return list.map((item) => LiveRoomModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('Canlı yayın listeleme hatası: $e');
    }
    return [];
  }

  // Canlı Yayın Başlat
  static Future<Map<String, dynamic>?> startLiveRoom({
    required int hostId,
    required String title,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiEndpoints.startLive),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'host_id': hostId, 'title': title}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Yayın başlatma hatası: $e');
    }
    return null;
  }

  // Hediye Listesini Al
  static Future<List<GiftModel>> getGifts() async {
    try {
      final res = await http.get(Uri.parse(ApiEndpoints.giftCatalog));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['gifts'] ?? [];
        return list.map((g) => GiftModel.fromJson(g)).toList();
      }
    } catch (e) {
      print('Hediye kataloğu hatası: $e');
    }
    return [];
  }

  // Canlı Yayında Hediye Gönder
  static Future<Map<String, dynamic>?> sendLiveGift({
    required int roomId,
    required int senderId,
    required int receiverId,
    required int giftId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiEndpoints.sendGift),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'room_id': roomId,
          'sender_id': senderId,
          'receiver_id': receiverId,
          'gift_id': giftId,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      print('Hediye gönderme hatası: $e');
      return null;
    }
  }

  // Cüzdan Bakiyesi
  static Future<Map<String, dynamic>?> getWallet(int userId) async {
    try {
      final res = await http.get(Uri.parse(ApiEndpoints.walletBalance(userId)));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Cüzdan hatası: $e');
    }
    return null;
  }

  // Google Play IAP Paketleri
  static Future<List<dynamic>> getIapPackages() async {
    try {
      final res = await http.get(Uri.parse(ApiEndpoints.iapPackages));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['packages'] ?? [];
      }
    } catch (e) {
      print('IAP paket hatası: $e');
    }
    return [];
  }

  // Google Play Makbuz Doğrulama
  static Future<Map<String, dynamic>?> verifyIapPurchase({
    required int userId,
    required String orderId,
    required String packageId,
    required String token,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiEndpoints.verifyIap),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'order_id': orderId,
          'package_id': packageId,
          'purchase_token': token,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }

  // Google Play UGC Şikayet Bildirimi
  static Future<bool> reportContent({
    required int reporterId,
    required String targetType,
    required int targetId,
    required String reason,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiEndpoints.report),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reporter_id': reporterId,
          'target_type': targetType,
          'target_id': targetId,
          'reason': reason,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
