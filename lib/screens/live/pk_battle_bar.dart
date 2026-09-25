import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/pk_model.dart';

class PkBattleBar extends StatefulWidget {
  final PkBattleModel battle;
  final VoidCallback onTimeExpired;

  const PkBattleBar({
    Key? key,
    required this.battle,
    required this.onTimeExpired,
  }) : super(key: key);

  @override
  State<PkBattleBar> createState() => _PkBattleBarState();
}

class _PkBattleBarState extends State<PkBattleBar> {
  Timer? _timer;
  int _secondsLeft = 300;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.battle.remainingSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
        widget.onTimeExpired();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final s1 = widget.battle.score1;
    final s2 = widget.battle.score2;
    final total = s1 + s2;
    // Oran hesabı (0 ise %50 - %50)
    final double flex1 = total == 0 ? 0.5 : (s1 / total).clamp(0.1, 0.9);
    final double flex2 = 1.0 - flex1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          // Üst Bilgi: Geri Sayım & Alevli Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('🔥 PK SAVAŞI', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(width: 8),
                    const Icon(Icons.timer, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(_formatTime(_secondsLeft), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Canlı Mavi vs Kırmızı Skor Barı
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 22,
              child: Stack(
                children: [
                  Row(
                    children: [
                      // Mavi Köşe (Sol - Host 1)
                      Expanded(
                        flex: (flex1 * 100).toInt(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0072FF), Color(0xFF00C6FF)],
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '$s1',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                      // Kırmızı Köşe (Sağ - Host 2)
                      Expanded(
                        flex: (flex2 * 100).toInt(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF0844), Color(0xFFFFB199)],
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '$s2',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Ortada Alevli VS Rozeti
                  Align(
                    alignment: Alignment(2 * flex1 - 1, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 1.5),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
