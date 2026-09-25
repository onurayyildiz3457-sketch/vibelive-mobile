import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/live_room_model.dart';
import '../services/api_service.dart';
import 'feed/fyp_screen.dart';
import 'live/live_room_screen.dart';
import 'wallet/wallet_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FypScreen(),
    const LiveExplorerPage(),
    const SizedBox(), // Ortadaki Video/Yayın Başlat Butonu modal açar
    const WalletScreen(),
    const ProfileScreen(),
  ];

  void _onAddPressed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Yeni İçerik Oluştur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.live_tv, color: Colors.white)),
              title: const Text('Canlı Yayın Başlat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('İzleyicilerinizle sohbet edin ve hediye toplayın', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                final res = await ApiService.startLiveRoom(
                  hostId: 1,
                  title: 'VibeLive Canlı Yayını 🔥 Sohbet & Eğlence',
                );
                if (res != null && mounted) {
                  final room = LiveRoomModel(
                    id: res['room']['id'],
                    hostId: 1,
                    channelName: res['room']['channel_name'],
                    title: res['room']['title'],
                    coverUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400',
                    status: 'active',
                    viewerCount: 1,
                    diamondsCollected: 0,
                    hostNickname: 'Sen (Yayıncı)',
                    hostAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LiveRoomScreen(room: room, isBroadcaster: true)));
                }
              },
            ),
            const Divider(color: AppColors.divider),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.secondary, child: Icon(Icons.videocam, color: Colors.black)),
              title: const Text('Kısa Video Yükle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Galerinizden veya kameranızdan video çekip paylaşın', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kamera ve video yükleyici açılıyor...'), backgroundColor: AppColors.primary),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _onAddPressed();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        selectedItemColor: Colors.white,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Keşfet'),
          const BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Canlı'),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Cüzdan'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}

// Canlı Yayınları Keşfet Sayfası
class LiveExplorerPage extends StatefulWidget {
  const LiveExplorerPage({Key? key}) : super(key: key);

  @override
  State<LiveExplorerPage> createState() => _LiveExplorerPageState();
}

class _LiveExplorerPageState extends State<LiveExplorerPage> {
  List<LiveRoomModel> _rooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() async {
    final list = await ApiService.getActiveLiveRooms();
    if (mounted) {
      setState(() {
        _rooms = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Canlı Yayınlar 🔥', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () async => _loadRooms(),
              color: AppColors.primary,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveRoomScreen(room: room, isBroadcaster: false),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        image: DecorationImage(
                          image: NetworkImage(room.coverUrl.isNotEmpty ? room.coverUrl : 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.8)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          // Canlı Rozeti
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.liveBadge,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('CANLI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          // İzleyici Sayısı
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.remove_red_eye, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text('${room.viewerCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                          // Alt Başlık ve Yayıncı
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    CircleAvatar(radius: 10, backgroundImage: NetworkImage(room.hostAvatar)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        room.hostNickname,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
