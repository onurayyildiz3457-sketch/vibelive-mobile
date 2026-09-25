class UserModel {
  final int id;
  final String username;
  final String nickname;
  final String avatar;
  final String bio;
  int coins;
  int diamonds;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
    this.bio = '',
    this.coins = 0,
    this.diamonds = 0,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 1,
      username: json['username'] ?? 'user',
      nickname: json['nickname'] ?? 'Kullanıcı',
      avatar: json['avatar'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      bio: json['bio'] ?? '',
      coins: json['coins'] ?? 0,
      diamonds: json['diamonds'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
    );
  }
}
