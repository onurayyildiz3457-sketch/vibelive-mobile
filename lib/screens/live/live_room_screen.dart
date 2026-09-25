import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/live_room_model.dart';
import '../../models/gift_model.dart';
import '../../models/pk_model.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import 'gift_dialog.dart';
import 'pk_battle_bar.dart';
import 'pk_invite_dialog.dart';
import '../profile/ugc_report_dialog.dart';

class LiveRoomScreen extends StatefulWidget {
  final LiveRoomModel room;
  final bool isBroadcaster;

  const LiveRoomScreen({
    Key? key,
    required this.room,
    this.isBroadcaster = false,
  }) : super(key: key);

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _msgCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final List<Widget> _floatingHearts = [];
  GiftModel? _activeGiftEffect;
  String _giftSenderName = '';

  // PK Savaşı Durumu
  PkBattleModel? _activePk;
  String? _pkWinnerAnnouncement;

  @override
  void initState() {
    super.initState();
    _connectLive();
  }

  void _connectLive() {
    final user = {
      'id': 1,
      'nickname': widget.isBroadcaster ? widget.room.hostNickname : 'Seyirci_Can',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    };

    SocketService.joinLiveRoom(widget.room.id, user);

    // Canlı sohbet dinle
    SocketService.socket.on('chat_message', (data) {
      if (mounted) {
        setState(() {
          _messages.add(Map<String, dynamic>.from(data));
        });
      }
    });

    // Canlı hediye patlaması dinle
    SocketService.socket.on('live_gift_received', (data) {
      if (mounted) {
        final giftData = data['gift'];
        final sender = data['sender'];
        setState(() {
          _activeGiftEffect = GiftModel.fromJson(giftData);
          _giftSenderName = sender['nickname'] ?? 'Bir Kullanıcı';
          widget.room.diamondsCollected += (giftData['coin_price'] as int? ?? 1);
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _activeGiftEffect = null;
            });
          }
        });
      }
    });

    // Canlı uçan kalpleri dinle
    SocketService.socket.on('live_heart_floating', (_) {
      _spawnFloatingHeart();
    });

    // PK SAVAŞI SOCKET DİNLEYİCİLERİ
    SocketService.socket.on('pk_started', (data) {
      if (mounted) {
        setState(() {
          _activePk = PkBattleModel.fromJson(data);
          _pkWinnerAnnouncement = null;
        });
      }
    });

    SocketService.socket.on('pk_score_update', (data) {
      if (mounted && _activePk != null) {
        setState(() {
          _activePk!.score1 = data['score1'] ?? _activePk!.score1;
          _activePk!.score2 = data['score2'] ?? _activePk!.score2;
        });
      }
    });

    SocketService.socket.on('pk_finished', (data) {
      if (mounted) {
        final winnerId = data['winner_id'];
        final isHost1Winner = (winnerId == _activePk?.host1Id);
        setState(() {
          _pkWinnerAnnouncement = winnerId == null
              ? '⚔️ PK BERABERE BİTTİ!'
              : (isHost1Winner ? '🏆 MAVİ KÖŞE KAZANDI!' : '🏆 KIRMIZI KÖŞE KAZANDI!');
        });
        Future.delayed(const Duration(seconds: 6), () {
          if (mounted) {
            setState(() {
              _activePk = null;
              _pkWinnerAnnouncement = null;
            });
          }
        });
      }
    });
  }

  void _spawnFloatingHeart() {
    if (!mounted) return;
    setState(() {
      _floatingHearts.add(
        Positioned(
          bottom: 100,
          right: 30 + (DateTime.now().millisecond % 50).toDouble(),
          child: const Icon(Icons.favorite, color: AppColors.primary, size: 32),
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _floatingHearts.isNotEmpty) {
        setState(() {
          _floatingHearts.removeAt(0);
        });
      }
    });
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    SocketService.sendChatMessage(widget.room.id, {
      'id': 1,
      'nickname': 'Seyirci_Can',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    }, text);
  }

  void _sendLike() {
    SocketService.sendLikeHeart(widget.room.id);
    _spawnFloatingHeart();
  }

  void _openGiftDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GiftDialog(
        roomId: widget.room.id,
        senderId: 1,
        receiverId: widget.room.hostId,
        receiverName: widget.room.hostNickname,
      ),
    );
  }

  // Yayıncı PK Meydan Okuma Menüsü
  void _openPkDialog() async {
    final opponentRoom = await showModalBottomSheet<LiveRoomModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PkInviteDialog(myHostId: widget.room.hostId, myRoomId: widget.room.id),
    );

    if (opponentRoom != null && mounted) {
      // PK Başlatma Simülasyonu
      setState(() {
        _activePk = PkBattleModel(
          id: DateTime.now().millisecondsSinceEpoch,
          host1Id: widget.room.hostId,
          host2Id: opponentRoom.hostId,
          room1Id: widget.room.id,
          room2Id: opponentRoom.id,
          score1: 0,
          score2: 0,
          remainingSeconds: 300,
          host1Name: widget.room.hostNickname,
          host1Avatar: widget.room.hostAvatar,
          host2Name: opponentRoom.hostNickname,
          host2Avatar: opponentRoom.hostAvatar,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚔️ ${opponentRoom.hostNickname} ile 5 Dakikalık PK Savaşı Başladı!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _reportRoom() {
    showDialog(
      context: context,
      builder: (_) => UgcReportDialog(
        targetType: 'live',
        targetId: widget.room.id,
        targetTitle: widget.room.title,
      ),
    );
  }

  @override
  void dispose() {
    SocketService.leaveLiveRoom(widget.room.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Canlı Video / Bölünmüş Ekran (Split-Screen Modu veya Tekli Yayın)
          _activePk != null ? _buildPkSplitVideo() : _buildSingleVideo(),

          // Karartma Katmanı
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. Üst Bilgi Barı (Yayıncı profili, izleyici sayısı, elmaslar, çıkış butonu)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Yayıncı Rozeti
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(widget.room.hostAvatar),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.room.hostNickname, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Row(
                                children: [
                                  const Icon(Icons.diamond, color: AppColors.diamond, size: 12),
                                  const SizedBox(width: 2),
                                  Text('${widget.room.diamondsCollected} Elmas', style: const TextStyle(color: AppColors.diamond, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Canlı İzleyici Rozeti
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.liveBadge,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_red_eye, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('${widget.room.viewerCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // UGC Şikayet Butonu
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: _reportRoom,
                    ),

                    // Çıkış Butonu
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. PK Savaşı Başlığı (Skor Barı & Geri Sayım)
          if (_activePk != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: PkBattleBar(
                    battle: _activePk!,
                    onTimeExpired: () {
                      setState(() {
                        _pkWinnerAnnouncement = _activePk!.score1 >= _activePk!.score2
                            ? '🏆 MAVİ KÖŞE KAZANDI! (CEZA TURU BAŞLADI)'
                            : '🏆 KIRMIZI KÖŞE KAZANDI! (CEZA TURU BAŞLADI)';
                      });
                    },
                  ),
                ),
              ),
            ),

          // 4. PK Kazananı Bildirimi (Alevli Zafer Başlığı)
          if (_pkWinnerAnnouncement != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black90,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: Text(
                  _pkWinnerAnnouncement!,
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),

          // 5. Canlı Sohbet Akışı
          Positioned(
            left: 16,
            bottom: 80,
            right: 100,
            height: 200,
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                if (m['type'] == 'system') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      m['text'] ?? '',
                      style: const TextStyle(color: AppColors.gold, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  );
                }
                final u = m['user'] ?? {};
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${u['nickname'] ?? 'Misafir'}: ',
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        TextSpan(
                          text: m['text'] ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 6. Uçan Kalpler Katmanı
          ..._floatingHearts,

          // 7. Tam Ekran Hediye Animasyonu
          if (_activeGiftEffect != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.gold, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_activeGiftEffect!.icon, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 12),
                    Text(
                      '$_giftSenderName',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_activeGiftEffect!.name} gönderdi!',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

          // 8. Alt Kontrol Çubuğu (Mesaj Yaz, Kalp, Hediye, PK Başlat Butonu)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Bir mesaj yaz...',
                        hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Yayıncı ise PK Başlat Butonu
                if (widget.isBroadcaster)
                  IconButton(
                    icon: const Text('⚔️', style: TextStyle(fontSize: 24)),
                    tooltip: 'PK Savaşı Başlat',
                    onPressed: _openPkDialog,
                  ),

                // Kalp At
                IconButton(
                  icon: const Icon(Icons.favorite, color: AppColors.primary, size: 30),
                  onPressed: _sendLike,
                ),

                // Hediye Gönder (İzleyici modu)
                if (!widget.isBroadcaster)
                  GestureDetector(
                    onTap: _openGiftDialog,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.card_giftcard, color: Colors.black, size: 22),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tekli Normal Yayın Görünümü
  Widget _buildSingleVideo() {
    return Image.network(
      widget.room.coverUrl.isNotEmpty ? widget.room.coverUrl : 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceLight),
    );
  }

  // PK Savaşı Bölünmüş Ekran (Split-Screen / Mavi Sol vs Kırmızı Sağ)
  Widget _buildPkSplitVideo() {
    return Row(
      children: [
        // Sol Taraf (Mavi Köşe - Host 1)
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.room.coverUrl.isNotEmpty ? widget.room.coverUrl : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF003366)),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00C6FF), width: 2),
                ),
              ),
              Positioned(
                bottom: 260,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF0072FF), borderRadius: BorderRadius.circular(10)),
                  child: Text(_activePk?.host1Name ?? 'Mavi', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),

        // Sağ Taraf (Kırmızı Köşe - Host 2 / Rakip)
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF660011)),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF0844), width: 2),
                ),
              ),
              Positioned(
                bottom: 260,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFF0844), borderRadius: BorderRadius.circular(10)),
                  child: Text(_activePk?.host2Name ?? 'Kırmızı', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
