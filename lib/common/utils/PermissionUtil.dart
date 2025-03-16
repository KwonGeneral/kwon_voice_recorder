// MARK: - 권한 유틸리티
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  // 싱글톤 인스턴스
  static final PermissionUtil _instance = PermissionUtil._internal();
  factory PermissionUtil() => _instance;
  PermissionUtil._internal();

  // 마이크 권한 요청
  Future<bool> requestMicrophonePermission() async {
    try {
      // 현재 권한 상태 확인
      PermissionStatus status = await Permission.microphone.status;

      // 권한이 이미 있는 경우
      if (status.isGranted) {
        Log.d('[PermissionUtil] 마이크 권한 이미 있음');
        return true;
      }

      // 권한 요청이 영구적으로 거부된 경우
      if (status.isPermanentlyDenied) {
        Log.d('[PermissionUtil] 마이크 권한 영구 거부됨, 앱 설정으로 안내 필요');
        return false;
      }

      // 권한 요청
      status = await Permission.microphone.request();
      Log.d('[PermissionUtil] 마이크 권한 요청 결과: $status');

      return status.isGranted;
    } catch (e) {
      Log.e('마이크 권한 요청 실패', StackTrace.current);
      return false;
    }
  }

  // 저장소 권한 요청 (Android용)
  Future<bool> requestStoragePermission() async {
    try {
      // Android 13 이상인 경우 오디오 미디어 권한
      if (await Permission.audio.request().isGranted) {
        return true;
      }

      // 구형 Android용 저장소 권한
      final status = await Permission.storage.request();
      Log.d('[PermissionUtil] 저장소 권한 요청 결과: $status');

      return status.isGranted;
    } catch (e) {
      Log.e('저장소 권한 요청 실패', StackTrace.current);
      return false;
    }
  }

  // 앱 설정 페이지로 이동
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // 녹음에 필요한 모든 권한 요청
  Future<bool> requestAllPermissions() async {
    final micPermission = await requestMicrophonePermission();
    final storagePermission = await requestStoragePermission();

    return micPermission && storagePermission;
  }
}