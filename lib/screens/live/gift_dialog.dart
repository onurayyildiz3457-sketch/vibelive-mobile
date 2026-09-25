import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/gift_model.dart';
import '../../services/api_service.dart';

class GiftDialog extends StatefulWidget {
  final int roomId;
  final int senderId;
  final int receiverId;
  final String receiverName;

  const GiftDialog({
    Key? key,
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<GiftDialog> createState() => _GiftDialogState();
}

class _GiftDialogState extends State<GiftDialog> {
  List<GiftModel> _gifts = [];
  GiftModel? _selectedGift;
  int _userCoins = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final gifts = await ApiService.getGifts();
    final wallet = await ApiService.getWallet(widget.senderId);
    if (mounted) {
      setState(() {
        _gifts = gifts;
        if (_gifts.isNotEmpty) _selectedGift = _gifts.first;
        _userCoins = wallet?['coins'] ?? 0;
        _loading = false;
      });
    }
  }

  void _sendGift() async {
    if (_selectedGift == null) return;
    if (_userCoins < _selectedGift!.coinPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yetersiz jeton! Lütfen cüzdanınızdan jeton yükleyin.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final res = await ApiService.sendLiveGift(
      roomId: widget.roomId,
      senderId: widget.senderId,
      receiverId: widget.receiverId,
      giftId: _selectedGift!.id,
    );

    if (res != null && res['success'] == true) {
      Navigator.pop(context, _selectedGift);
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.receiverName}\'a Hediye Gönder',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: AppColors.gold, size: 18),
                    const SizedBox(width: 4),
                    Text('$_userCoins Jeton', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),

          // Hediye Izgarası (Grid)
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _gifts.length,
                    itemBuilder: (context, index) {
                      final gift = _gifts[index];
                      final isSelected = _selectedGift?.id == gift.id;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedGift = gift),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.surfaceLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.gold : Colors.white12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(gift.icon, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 4),
                              Text(
                                gift.name.split(' ')[0],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.monetization_on, color: AppColors.gold, size: 12),
                                  const SizedBox(width: 2),
                                  Text('${gift.coinPrice}', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Alt Gönder Butonu & Bakiye Yükle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendGift,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(
                      _selectedGift != null ? '${_selectedGift!.name.split(" ")[0]} Gönder (${_selectedGift!.coinPrice} Jeton)' : 'Gönder',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
