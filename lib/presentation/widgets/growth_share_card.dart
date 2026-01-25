import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../design_system/tokens/colors.dart';
import '../design_system/tokens/typography.dart';
import '../design_system/tokens/spacing.dart';

/// 성장 데이터 공유 카드 위젯
///
/// 아기의 성장 정보를 시각적으로 표현하고,
/// 스크린샷을 찍어 공유할 수 있는 카드입니다.
///
/// Features:
/// - Midnight Blue 그라데이션 배경
/// - 아기 정보 (이름, 나이, 성별)
/// - 성장 측정값 (체중, 신장, 두위)
/// - 백분위수 정보
/// - 스크린샷 및 공유 기능
/// - Lulu 로고 워터마크
class GrowthShareCard extends StatefulWidget {
  /// 아기 이름
  final String babyName;

  /// 나이 텍스트 (예: "3개월 5일", "교정 2개월")
  final String ageText;

  /// 성별 ('male' 또는 'female')
  final String gender;

  /// 체중 (kg)
  final double? weightKg;

  /// 체중 백분위수
  final double? weightPercentile;

  /// 신장 (cm)
  final double? heightCm;

  /// 신장 백분위수
  final double? heightPercentile;

  /// 두위 (cm)
  final double? headCircumferenceCm;

  /// 두위 백분위수
  final double? headCircumferencePercentile;

  /// 측정 날짜
  final DateTime measurementDate;

  /// 추가 메모 (선택사항)
  final String? note;

  const GrowthShareCard({
    super.key,
    required this.babyName,
    required this.ageText,
    required this.gender,
    this.weightKg,
    this.weightPercentile,
    this.heightCm,
    this.heightPercentile,
    this.headCircumferenceCm,
    this.headCircumferencePercentile,
    required this.measurementDate,
    this.note,
  });

  @override
  State<GrowthShareCard> createState() => _GrowthShareCardState();
}

class _GrowthShareCardState extends State<GrowthShareCard> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  /// 스크린샷 촬영 및 공유
  Future<void> _captureAndShare() async {
    setState(() {
      _isSharing = true;
    });

    try {
      // 스크린샷 촬영
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0, // 고해상도
      );

      if (imageBytes == null) {
        throw Exception('스크린샷 생성 실패');
      }

      // 임시 파일로 저장하여 공유
      final String fileName =
          'lulu_growth_${widget.babyName}_${DateTime.now().millisecondsSinceEpoch}.png';

      await Share.shareXFiles(
        [
          XFile.fromData(
            imageBytes,
            name: fileName,
            mimeType: 'image/png',
          ),
        ],
        text: '${widget.babyName}의 성장 기록 - Lulu',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('공유 중 오류가 발생했습니다: $e'),
            backgroundColor: LuluColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 스크린샷 대상 카드
        Screenshot(
          controller: _screenshotController,
          child: _buildShareableCard(),
        ),
        const SizedBox(height: LuluSpacing.md),
        // 공유 버튼
        _buildShareButton(),
      ],
    );
  }

  /// 공유 가능한 카드 위젯
  Widget _buildShareableCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A), // Midnight Blue
            Color(0xFF312E81), // Deep Indigo
            Color(0xFF1E293B), // Slate 800
          ],
        ),
        borderRadius: BorderRadius.circular(LuluSpacing.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(LuluSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (아기 정보)
            _buildHeader(),
            const SizedBox(height: LuluSpacing.lg),
            // 성장 측정값
            _buildMeasurements(),
            const SizedBox(height: LuluSpacing.lg),
            // 푸터 (날짜 및 워터마크)
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// 헤더 (아기 정보)
  Widget _buildHeader() {
    return Row(
      children: [
        // 아기 아이콘
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(LuluSpacing.borderRadiusMd),
          ),
          child: Center(
            child: Text(
              widget.gender == 'male' ? '👶' : '👧',
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
        const SizedBox(width: LuluSpacing.md),
        // 이름 및 나이
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.babyName,
                style: LuluTypography.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: LuluSpacing.xs),
              Text(
                widget.ageText,
                style: LuluTypography.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 성장 측정값
  Widget _buildMeasurements() {
    return Column(
      children: [
        if (widget.weightKg != null)
          _buildMeasurementRow(
            icon: '⚖️',
            label: '체중',
            value: '${widget.weightKg!.toStringAsFixed(1)}kg',
            percentile: widget.weightPercentile,
          ),
        if (widget.heightCm != null) ...[
          const SizedBox(height: LuluSpacing.md),
          _buildMeasurementRow(
            icon: '📏',
            label: '신장',
            value: '${widget.heightCm!.toStringAsFixed(1)}cm',
            percentile: widget.heightPercentile,
          ),
        ],
        if (widget.headCircumferenceCm != null) ...[
          const SizedBox(height: LuluSpacing.md),
          _buildMeasurementRow(
            icon: '👶',
            label: '두위',
            value: '${widget.headCircumferenceCm!.toStringAsFixed(1)}cm',
            percentile: widget.headCircumferencePercentile,
          ),
        ],
        if (widget.note != null && widget.note!.isNotEmpty) ...[
          const SizedBox(height: LuluSpacing.md),
          Container(
            padding: const EdgeInsets.all(LuluSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(LuluSpacing.borderRadiusSm),
            ),
            child: Text(
              widget.note!,
              style: LuluTypography.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 측정값 행
  Widget _buildMeasurementRow({
    required String icon,
    required String label,
    required String value,
    double? percentile,
  }) {
    return Container(
      padding: const EdgeInsets.all(LuluSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(LuluSpacing.borderRadiusMd),
      ),
      child: Row(
        children: [
          // 아이콘
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: LuluSpacing.md),
          // 라벨
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: LuluTypography.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: LuluSpacing.xs),
                Text(
                  value,
                  style: LuluTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 백분위수
          if (percentile != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LuluSpacing.sm,
                vertical: LuluSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getPercentileColor(percentile),
                borderRadius: BorderRadius.circular(LuluSpacing.borderRadiusSm),
              ),
              child: Text(
                'P${percentile.round()}',
                style: LuluTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 백분위수에 따른 색상 반환
  Color _getPercentileColor(double percentile) {
    if (percentile < 3) {
      return LuluColors.error; // 성장 부진
    } else if (percentile < 10) {
      return LuluColors.warning; // 주의
    } else if (percentile > 97) {
      return LuluColors.warning; // 과체중 주의
    } else if (percentile > 90) {
      return LuluColors.success; // 양호 (상위)
    } else {
      return LuluColors.primary; // 정상
    }
  }

  /// 푸터 (날짜 및 워터마크)
  Widget _buildFooter() {
    return Column(
      children: [
        // 구분선
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.2),
        ),
        const SizedBox(height: LuluSpacing.md),
        // 날짜 및 워터마크
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 측정 날짜
            Text(
              '${widget.measurementDate.year}.${widget.measurementDate.month.toString().padLeft(2, '0')}.${widget.measurementDate.day.toString().padLeft(2, '0')}',
              style: LuluTypography.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            // Lulu 워터마크
            Row(
              children: [
                Text(
                  'Made with ',
                  style: LuluTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                Text(
                  'Lulu',
                  style: LuluTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: LuluSpacing.xs),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: LuluColors.primary,
                    borderRadius:
                        BorderRadius.circular(LuluSpacing.borderRadiusSm),
                  ),
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 공유 버튼
  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSharing ? null : _captureAndShare,
        icon: _isSharing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.share),
        label: Text(
          _isSharing ? '공유 준비 중...' : '성장 기록 공유하기',
          style: LuluTypography.labelLarge,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: LuluColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: LuluSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuluSpacing.borderRadiusMd),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
