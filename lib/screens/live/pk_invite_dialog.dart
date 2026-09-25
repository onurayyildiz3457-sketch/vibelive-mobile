import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/live_room_model.dart';
import '../../services/api_service.dart';

class PkInviteDialog extends StatefulWidget {
  final int myHostId;
  final int myRoomId;

  const PkInviteDialog({
    Key? key,
    required this.myHostId,
    required this.myRoomId,
  }) : super(key: key);

  @override
  State<PkInviteDialog> createState() => _PkInviteDialogState();
}

class _PkInviteDialogState extends State<PkInviteDialog> {
  List<LiveRoomModel> _activeRooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOtherBroadcasters();
  }

  void _loadOtherBroadcasters() async {
    final list = await ApiService.getActiveLiveRooms();
    if (mounted) {
      setState(() {
        // Kendi odasını filtrele, sadece rakipleri listele
        _activeRooms = list.where((r) => r.id != widget.myRoomId).toList();
        _loading = false;
      });
    }
  }

  void _sendPkInvite(LiveRoomModel opponentRoom) async {
    // PK Başlat
    Navigator.pop(context, opponentRoom);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: const [
                Text('⚔️', style: TextStyle(fontSize: 22)),
                SizedBox(width: 8),
                Text(
                  'PK Canlı Yayın Savaşı Başlat',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),

          // Liste
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _activeRooms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.person_off_rounded, color: AppColors.textSecondary, size: 40),
                            SizedBox(height: 8),
                            Text('Şu anda müsait başka yayıncı yok.', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _activeRooms.length,
                        itemBuilder: (context, index) {
                          final r = _activeRooms[index];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(r.hostAvatar),
                            ),
                            title: Text(r.hostNickname, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text('🔥 ${r.diamondsCollected} Elmas • ${r.viewerCount} İzleyici', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            trailing: ElevatedButton(
                              onPressed: () => _sendPkInvite(r),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              child: const Text('Meydan Oku ⚔️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
