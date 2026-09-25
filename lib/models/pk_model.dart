class PkBattleModel {
  final int id;
  final int host1Id;
  final int host2Id;
  final int room1Id;
  final int room2Id;
  int score1;
  int score2;
  String status;
  int remainingSeconds;
  final String host1Name;
  final String host1Avatar;
  final String host2Name;
  final String host2Avatar;

  PkBattleModel({
    required this.id,
    required this.host1Id,
    required this.host2Id,
    required this.room1Id,
    required this.room2Id,
    this.score1 = 0,
    this.score2 = 0,
    this.status = 'active',
    this.remainingSeconds = 300,
    required this.host1Name,
    required this.host1Avatar,
    required this.host2Name,
    required this.host2Avatar,
  });

  factory PkBattleModel.fromJson(Map<String, dynamic> json) {
    return PkBattleModel(
      id: json['id'] ?? json['battle_id'] ?? 0,
      host1Id: json['host1_id'] ?? 1,
      host2Id: json['host2_id'] ?? 2,
      room1Id: json['room1_id'] ?? 1,
      room2Id: json['room2_id'] ?? 2,
      score1: json['score1'] ?? 0,
      score2: json['score2'] ?? 0,
      status: json['status'] ?? 'active',
      remainingSeconds: json['duration'] ?? json['remaining_seconds'] ?? 300,
      host1Name: json['host1_name'] ?? 'Mavi Köşe',
      host1Avatar: json['host1_avatar'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      host2Name: json['host2_name'] ?? 'Kırmızı Köşe',
      host2Avatar: json['host2_avatar'] ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    );
  }
}
