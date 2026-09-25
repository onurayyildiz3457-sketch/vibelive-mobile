import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';

class UgcReportDialog extends StatefulWidget {
  final String targetType; // 'video', 'live', 'user'
  final int targetId;
  final String targetTitle;

  const UgcReportDialog({
    Key? key,
    required this.targetType,
    required this.targetId,
    required this.targetTitle,
  }) : super(key: key);

  @override
  State<UgcReportDialog> createState() => _UgcReportDialogState();
}

class _UgcReportDialogState extends State<UgcReportDialog> {
  String _selectedReason = 'Uygunsuz İçerik / Müstehcenlik';

  final List<String> _reasons = [
    'Uygunsuz İçerik / Müstehcenlik',
    'Zorbalık veya Taciz',
    'Şiddet veya Tehlikeli Davranış',
    'Nefret Söylemi',
    'Spam veya Yanıltıcı İçerik',
    'Telif Hakkı İhlali',
  ];

  void _submitReport() async {
    final ok = await ApiService.reportContent(
      reporterId: 1,
      targetType: widget.targetType,
      targetId: widget.targetId,
      reason: _selectedReason,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Şikayetiniz moderasyon ekibine iletildi. Teşekkürler.' : 'Bir hata oluştu.'),
          backgroundColor: ok ? Colors.green : AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('İçeriği Şikayet Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lütfen şikayet gerekçenizi seçin:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          ..._reasons.map((r) {
            return RadioListTile<String>(
              value: r,
              groupValue: _selectedReason,
              activeColor: AppColors.primary,
              title: Text(r, style: const TextStyle(color: Colors.white, fontSize: 13)),
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                if (val != null) setState(() => _selectedReason = val);
              },
            );
          }).toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _submitReport,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Şikayet Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
