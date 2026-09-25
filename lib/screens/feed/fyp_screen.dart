import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/video_model.dart';
import '../../services/api_service.dart';
import 'comments_sheet.dart';
import '../live/gift_dialog.dart';
import '../profile/ugc_report_dialog.dart';

class FypScreen extends StatefulWidget {
  const FypScreen({Key? key}) : super(key: key);

  @override
  State<FypScreen> createState() => _FypScreenState();
}

class _FypScreenState extends State<FypScreen> {
  final PageController _pageController = PageController();
  List<VideoModel> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  void _loadFeed() async {
    final list = await ApiService.getFeed();
    if (mounted) {
      setState(() {
        _videos = list;
        _loading = false;
      });
    }
  }

  void _toggleLike(VideoModel video) async {
    setState(() {
      video.isLiked = !video.isLiked;
      video.likesCount += video.isLiked ? 1 : -1;
    });
    await ApiService.toggleLike(video.id, 1);
  }

  void _openComments(VideoModel video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(videoId: video.id, commentsCount: video.commentsCount),
    );
  }

  void _openGiftDialog(VideoModel video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GiftDialog(
        roomId: 1,
        senderId: 1,
        receiverId: video.userId,
        receiverName: video.nickname,
      ),
    );
  }

  void _openReport(VideoModel video) {
    showDialog(
      context: context,
      builder: (_) => UgcReportDialog(
        targetType: 'video',
        targetId: video.id,
        targetTitle: video.caption,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_videos.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Henüz video bulunamadı', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadFeed,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Yenile', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              // Video / Arka Plan Görseli
              Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceLight),
              ),

              // Hafif Karartma Katmanı
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Üst Sekmeler (Takip Edilenler | Keşfet)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Takip Edilen', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 16),
                        Text('|', style: TextStyle(color: AppColors.divider)),
                        SizedBox(width: 16),
                        Text('Keşfet', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),

              // Sağ Etkileşim Butonları (TikTok Dikey Buton Grubu)
              Positioned(
                right: 12,
                bottom: 80,
                child: Column(
                  children: [
                    // Profil Fotoğrafı & Takip Et Butonu
                    Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(video.avatar),
                        ),
                        Positioned(
                          bottom: -6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Kalp (Beğeni)
                    GestureDetector(
                      onTap: () => _toggleLike(video),
                      child: Column(
                        children: [
                          Icon(
                            video.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: video.isLiked ? AppColors.primary : Colors.white,
                            size: 38,
                          ),
                          const SizedBox(height: 4),
                          Text('${video.likesCount}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Yorum
                    GestureDetector(
                      onTap: () => _openComments(video),
                      child: Column(
                        children: [
                          const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 34),
                          const SizedBox(height: 4),
                          Text('${video.commentsCount}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Hediye Gönder (Canlı Hediye Tepsisi)
                    GestureDetector(
                      onTap: () => _openGiftDialog(video),
                      child: Column(
                        children: const [
                          Icon(Icons.card_giftcard_rounded, color: AppColors.gold, size: 34),
                          SizedBox(height: 4),
                          Text('Hediye', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Google Play UGC Şikayet Et
                    GestureDetector(
                      onTap: () => _openReport(video),
                      child: Column(
                        children: const [
                          Icon(Icons.more_horiz_rounded, color: Colors.white70, size: 30),
                          SizedBox(height: 4),
                          Text('Bildir', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Dönen Müzik Plağı Animasyonu
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black82,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),

              // Sol Alt Bilgi Alanı (Yazar, Açıklama, Müzik)
              Positioned(
                left: 16,
                bottom: 30,
                right: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${video.username}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            video.soundName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
