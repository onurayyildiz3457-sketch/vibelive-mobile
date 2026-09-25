class ApiEndpoints {
  // Canlı Ubuntu Sunucunuzdaki VibeLive API Uç Noktası
  static const String serverHost = '159.195.61.212:4000';
  static const String baseUrl = 'http://$serverHost/api';
  static const String socketUrl = 'http://$serverHost';

  // Video Akışı (FYP)
  static const String feed = '$baseUrl/videos/feed';
  static String likeVideo(int id) => '$baseUrl/videos/$id/like';
  static String comments(int id) => '$baseUrl/videos/$id/comments';

  // Canlı Yayın (Live Streaming)
  static const String activeLiveRooms = '$baseUrl/live/active';
  static const String startLive = '$baseUrl/live/start';
  static String joinLive(int id) => '$baseUrl/live/$id/join';
  static String endLive(int id) => '$baseUrl/live/$id/end';
  static const String giftCatalog = '$baseUrl/live/gifts';
  static const String sendGift = '$baseUrl/live/send-gift';

  // Cüzdan & Google Play IAP
  static String walletBalance(int userId) => '$baseUrl/wallet/balance/$userId';
  static const String iapPackages = '$baseUrl/wallet/packages';
  static const String verifyIap = '$baseUrl/wallet/verify-iap';
  static const String withdraw = '$baseUrl/wallet/withdraw';

  // Google Play UGC Şikayet / Engelleme
  static const String report = '$baseUrl/ugc/report';
  static const String blockUser = '$baseUrl/ugc/block';
}
