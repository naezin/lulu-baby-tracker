import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/baby_model.dart';
import '../providers/baby_provider.dart';

/// 아기 전환 드롭다운 위젯
/// 홈 화면 상단에 배치
class BabySwitcher extends StatelessWidget {
  const BabySwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BabyProvider>(
      builder: (context, provider, child) {
        // 아기가 1명이면 표시 안함
        if (!provider.hasMultipleBabies) {
          return const SizedBox.shrink();
        }

        final currentBaby = provider.currentBaby;
        if (currentBaby == null) {
          return const SizedBox.shrink();
        }

        return _buildSwitcher(context, provider, currentBaby);
      },
    );
  }

  Widget _buildSwitcher(
    BuildContext context,
    BabyProvider provider,
    BabyModel currentBaby,
  ) {
    return GestureDetector(
      onTap: () => _showBabySelector(context, provider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard.withOpacity(0.5),  // 🔧 cardBackground → surfaceCard
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.lavenderMist.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아기 아바타
            _buildAvatar(currentBaby),
            const SizedBox(width: 8),
            // 아기 이름
            Text(
              currentBaby.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            // 드롭다운 아이콘
            Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.lavenderMist,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BabyModel baby) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBabyColor(baby.id),
      ),
      child: Center(
        child: Text(
          baby.name.isNotEmpty ? baby.name[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Color _getBabyColor(String babyId) {
    // 아기 ID 해시값 기반으로 색상 결정
    final colors = [
      const Color(0xFF6B9DFF), // Sky Blue
      const Color(0xFFB19CD9), // Lavender
      const Color(0xFF98D8AA), // Mint
      const Color(0xFFFFB366), // Peach
      const Color(0xFFFFE066), // Lemon
    ];
    return colors[babyId.hashCode.abs() % colors.length];
  }

  void _showBabySelector(BuildContext context, BabyProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,  // 🔧 cardBackground → surfaceCard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BabySelectorSheet(provider: provider),
    );
  }
}

class _BabySelectorSheet extends StatelessWidget {
  final BabyProvider provider;

  const _BabySelectorSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.translate('select_baby') ?? '아기 선택',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 아기 목록
            ...provider.babies.map((baby) => _buildBabyTile(context, baby)),

            const SizedBox(height: 16),

            // 아기 추가 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add-baby');
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.translate('add_baby') ?? '아기 추가'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.lavenderMist,
                  side: BorderSide(color: AppTheme.lavenderMist),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBabyTile(BuildContext context, BabyModel baby) {
    final isSelected = baby.id == provider.currentBabyId;

    return ListTile(
      leading: _buildAvatar(baby, isSelected),
      title: Text(
        baby.name,
        style: TextStyle(
          color: isSelected ? AppTheme.lavenderMist : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        _formatAge(baby),
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppTheme.lavenderMist)
          : null,
      onTap: () async {
        await provider.switchBaby(baby.id);
        if (context.mounted) {
          Navigator.pop(context);
          // 전환 완료 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${baby.name}(으)로 전환했어요 💜'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  Widget _buildAvatar(BabyModel baby, bool isSelected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBabyColor(baby.id),
        border: isSelected
            ? Border.all(color: AppTheme.lavenderMist, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          baby.name.isNotEmpty ? baby.name[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Color _getBabyColor(String babyId) {
    final colors = [
      const Color(0xFF6B9DFF),
      const Color(0xFFB19CD9),
      const Color(0xFF98D8AA),
      const Color(0xFFFFB366),
      const Color(0xFFFFE066),
    ];
    return colors[babyId.hashCode.abs() % colors.length];
  }

  String _formatAge(BabyModel baby) {
    final birthDate = DateTime.parse(baby.birthDate);
    final now = DateTime.now();
    final days = now.difference(birthDate).inDays;

    if (days < 30) {
      return '생후 ${days}일';
    } else {
      final months = (now.year - birthDate.year) * 12 +
          now.month -
          birthDate.month;
      return '생후 ${months}개월';
    }
  }
}
