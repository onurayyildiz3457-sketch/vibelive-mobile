class GiftModel {
  final int id;
  final String name;
  final int coinPrice;
  final String icon;
  final String animationType;

  GiftModel({
    required this.id,
    required this.name,
    required this.coinPrice,
    required this.icon,
    required this.animationType,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      coinPrice: json['coin_price'] ?? 1,
      icon: json['icon'] ?? '🎁',
      animationType: json['animation_type'] ?? 'fly_center',
    );
  }
}
