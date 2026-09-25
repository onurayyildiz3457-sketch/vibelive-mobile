class LiveRoomModel {
  final int id;
  final int hostId;
  final String channelName;
  final String title;
  final String coverUrl;
  final String status;
  int viewerCount;
  int diamondsCollected;
  final String hostNickname;
  final String hostAvatar;

  LiveRoomModel({
    required this.id,
    required this.hostId,
    required this.channelName,
    required this.title,
    required this.coverUrl,
    required this.status,
    required this.viewerCount,
    required this.diamondsCollected,
    required this.hostNickname,
    required this.hostAvatar,
  });

  factory LiveRoomModel.fromJson(Map<String, dynamic> json) {
    return LiveRoomModel(
      id: json['id'] ?? 0,
      hostId: json['host_id'] ?? 0,
      channelName: json['channel_name'] ?? '',
      title: json['title'] ?? 'VibeLive Canlı Yayını',
      coverUrl: json['cover_url'] ?? '',
      status: json['status'] ?? 'active',
      viewerCount: json['viewer_count'] ?? 0,
      diamondsCollected: json['diamonds_collected'] ?? 0,
      hostNickname: json['host_nickname'] ?? json['nickname'] ?? 'Yayıncı',
      hostAvatar: json['host_avatar'] ?? json['avatar'] ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    );
  }
}
