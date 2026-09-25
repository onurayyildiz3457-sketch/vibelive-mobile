class VideoModel {
  final int id;
  final int userId;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final String soundName;
  int likesCount;
  int commentsCount;
  bool isLiked;
  final String username;
  final String nickname;
  final String avatar;

  VideoModel({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.soundName,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.username,
    required this.nickname,
    required this.avatar,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      caption: json['caption'] ?? '',
      soundName: json['sound_name'] ?? 'Orijinal Ses',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: (json['is_liked'] == 1 || json['is_liked'] == true),
      username: json['username'] ?? 'creator',
      nickname: json['nickname'] ?? 'İçerik Üreticisi',
      avatar: json['avatar'] ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    );
  }
}
