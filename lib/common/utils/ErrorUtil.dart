// MARK: - 오류 처리 유틸리티
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:kwon_voice_recorder/presenter/style/TextStyles.dart';
import 'package:kwon_voice_recorder/presenter/theme/Themes.dart';

class ErrorUtil {
  // 싱글톤 인스턴스
  static final ErrorUtil _instance = ErrorUtil._internal();
  factory ErrorUtil() => _instance;
  ErrorUtil._internal();

  // 일반 오류 메시지 표시
  void showError(String message, {String? title, VoidCallback? onRetry}) {
    Get.snackbar(
      title ?? '오류',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      mainButton: onRetry != null
          ? TextButton(
        onPressed: onRetry,
        child: Text(
          '다시 시도',
          style: TextStyles.bold(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      )
          : null,
    );
  }

  // 권한 오류 메시지 표시
  void showPermissionError({required VoidCallback onOpenSettings}) {
    Get.snackbar(
      '권한 필요',
      '녹음을 위해 마이크 권한이 필요합니다.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: KwonThemes().primary.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: onOpenSettings,
        child: Text(
          '설정 열기',
          style: TextStyles.bold(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // 오류 다이얼로그 표시
  void showErrorDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmText,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          title,
          style: TextStyles.bold(
            fontSize: 18,
            color: KwonThemes().surface01,
          ),
        ),
        content: Text(
          message,
          style: TextStyles.regular(
            fontSize: 14,
            color: KwonThemes().black70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '취소',
              style: TextStyles.medium(
                fontSize: 14,
                color: KwonThemes().black60,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText ?? '확인',
              style: TextStyles.medium(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 로그 오류 기록
  void logError(dynamic error, StackTrace stackTrace, {String? tag}) {
    Log.e(error, stackTrace, tag: tag ?? 'ERROR');
  }
}