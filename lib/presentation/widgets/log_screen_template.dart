import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// 🎨 기록 화면 공통 템플릿
/// 모든 기록 화면(수면, 수유, 기저귀, 놀이, 건강)이 이 템플릿을 사용합니다.
class LogScreenTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final Widget? contextHint;        // 💡 기록 전 도움말 (선택적)
  final Widget inputSection;        // 📝 입력 섹션
  final String saveButtonText;
  final VoidCallback onSave;
  final bool isLoading;

  const LogScreenTemplate({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    this.contextHint,
    required this.inputSection,
    this.saveButtonText = '저장하기',
    required this.onSave,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1321), // Midnight Blue
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(title),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎨 HEADER CARD
                  _buildHeaderCard(context),
                  const SizedBox(height: 16),

                  // 💡 CONTEXT HINT (선택적)
                  if (contextHint != null) ...[
                    _buildContextHintCard(context),
                    const SizedBox(height: 16),
                  ],

                  // 📝 INPUT SECTION
                  _buildInputCard(context),
                ],
              ),
            ),
          ),

          // 💾 SAVE BUTTON (하단 고정)
          _buildSaveButton(context),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: themeColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextHintCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),  // Glassmorphism
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber[300], size: 20),
          const SizedBox(width: 12),
          Expanded(child: contextHint!),
        ],
      ),
    );
  }

  Widget _buildInputCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),  // Glassmorphism
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: inputSection,
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1321),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : () {
          HapticFeedback.mediumImpact();
          onSave();
        },
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                saveButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// 🔘 통일된 선택 버튼 위젯
class LogOptionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color themeColor;
  final VoidCallback onTap;

  const LogOptionButton({
    Key? key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.themeColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? themeColor.withOpacity(0.2)
              : const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? themeColor : const Color(0x33FFFFFF),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? themeColor : Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? themeColor : Colors.grey[400],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📊 저장 후 피드백 표시 함수
void showPostRecordFeedback({
  required BuildContext context,
  required String title,
  required List<String> insights,
  required Color themeColor,
}) {
  HapticFeedback.heavyImpact();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (bottomSheetContext) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2332),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // 성공 아이콘
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: themeColor, size: 32),
          ),
          const SizedBox(height: 16),

          // 제목
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // 인사이트 목록
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  insight.length >= 2 ? insight.substring(0, 2) : '',  // 이모지
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.length >= 2 ? insight.substring(2).trim() : insight,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),

          SizedBox(height: MediaQuery.of(bottomSheetContext).padding.bottom + 16),
        ],
      ),
    ),
  ).then((_) {
    // 바텀시트가 닫힌 후 (수동이든 자동이든) 로그 화면도 바로 닫기
    // 약간의 딜레이를 주어 바텀시트 애니메이션이 완료된 후 닫음
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  });

  // 3초 후 자동으로 바텀시트 닫기
  Future.delayed(const Duration(seconds: 3), () {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);  // 바텀시트 닫기 (그러면 .then()이 실행되어 로그 화면도 닫힘)
    }
  });
}
