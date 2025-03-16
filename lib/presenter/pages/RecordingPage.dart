

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kwon_voice_recorder/common/types/RecordStatus.dart';
import 'package:kwon_voice_recorder/common/utils/ErrorUtil.dart';
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:kwon_voice_recorder/common/utils/PermissionUtil.dart';
import 'package:kwon_voice_recorder/data/service/RecordService.dart';
import 'package:kwon_voice_recorder/domain/usecase/PauseRecordUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/StartRecordUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/StopRecordUseCase.dart';
import 'package:kwon_voice_recorder/injection/injection.dart';
import 'package:kwon_voice_recorder/presenter/BaseViewModel.dart';
import 'package:kwon_voice_recorder/presenter/style/TextStyles.dart';
import 'package:kwon_voice_recorder/presenter/theme/Themes.dart';

// MARK: - 녹음 페이지
class RecordingPage extends StatelessWidget {
  const RecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecordingPageViewModel>(
      init: RecordingPageViewModel(),
      builder: (model) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '녹음',
              style: TextStyles.bold(fontSize: 18, color: KwonThemes().surface01),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: KwonThemes().backgroundSub,
          ),
          body: SafeArea(
            child: Container(
              color: KwonThemes().background,
              // 에러 상태일 때 에러 UI 표시
              child: model.hasError
                  ? _buildErrorState(model)
                  : Column(
                children: [
                  // 상단 공간
                  const SizedBox(height: 40),

                  // 녹음 시간 표시
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            model.formattedDuration,
                            style: TextStyles.bold(
                              fontSize: 60,
                              color: KwonThemes().surface01,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getStatusText(model.recordStatus),
                            style: TextStyles.medium(
                              fontSize: 16,
                              color: KwonThemes().black60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 오디오 시각화 (파형)
                  Expanded(
                    flex: 3,
                    child: model.recordStatus == RecordStatus.PLAY
                        ? Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            9, // 고정된 개수의 바
                                (index) {
                              // 각 바마다 약간 다른 높이를 설정 (음성 파형 효과)
                              final baseHeight = model.recordStatus == RecordStatus.PLAY
                                  ? (model.audioLevels.isNotEmpty ? model.audioLevels[index % model.audioLevels.length] : 0.3)
                                  : 0.3;

                              Log.d('[RecordingPage] 파형 바 #$index 높이: $baseHeight');

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                width: 5,
                                height: 80 * baseHeight,
                                decoration: BoxDecoration(
                                  color: KwonThemes().primary.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                        : Container(),
                  ),

                  // 녹음 컨트롤 버튼
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 중지 버튼 (녹음 중 또는 일시정지 상태일 때만 표시)
                          if (model.recordStatus == RecordStatus.PLAY ||
                              model.recordStatus == RecordStatus.PAUSE)
                            _buildControlButton(
                              icon: Icons.stop,
                              color: Colors.red,
                              onTap: () => model.stopRecord(),
                              text: '중지',
                            ),

                          const SizedBox(width: 40),

                          // 녹음 시작/일시정지 버튼
                          _buildMainButton(model),
                        ],
                      ),
                    ),
                  ),

                  // 하단 여백
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 에러 상태 UI
  Widget _buildErrorState(RecordingPageViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            model.errorMessage,
            style: TextStyles.medium(
              fontSize: 16,
              color: KwonThemes().black70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => model.startRecord(),
            style: ElevatedButton.styleFrom(
              backgroundColor: KwonThemes().primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              '다시 시도',
              style: TextStyles.medium(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 녹음 상태 텍스트
  String _getStatusText(RecordStatus status) {
    switch (status) {
      case RecordStatus.PLAY:
        return '녹음 중...';
      case RecordStatus.PAUSE:
        return '일시정지됨';
      case RecordStatus.STOP:
      case RecordStatus.NONE:
        return '녹음 준비됨';
    }
  }

  // 메인 녹음 버튼
  Widget _buildMainButton(RecordingPageViewModel model) {
    final isRecording = model.recordStatus == RecordStatus.PLAY;
    final isPaused = model.recordStatus == RecordStatus.PAUSE;

    return InkWell(
      onTap: () {
        if (isRecording) {
          model.pauseRecord();
        } else {
          model.startRecord();
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isRecording ? KwonThemes().primary.withOpacity(0.8) : KwonThemes().primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: KwonThemes().black20,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.pause : Icons.mic,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  // 컨트롤 버튼 (중지, 일시정지 등)
  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String text,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: KwonThemes().black10,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyles.medium(
            fontSize: 14,
            color: KwonThemes().black60,
          ),
        ),
      ],
    );
  }

  // 오디오 파형 시각화 (간단한 애니메이션)
  Widget _buildWaveformAnimation(RecordingPageViewModel model) {
    return Center(
      child: SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            model.audioLevels.length,
                (index) => _buildBar(index, model.audioLevels[index]),
          ),
        ),
      ),
    );
  }

  // 파형 바
  Widget _buildBar(int index, double level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 5,
        height: 80 * level,
        decoration: BoxDecoration(
          color: KwonThemes().primary.withOpacity(0.7),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  // 랜덤 높이 생성 (파형 애니메이션용)
  double _getRandomHeight() {
    // 0.3에서 1.0 사이의 랜덤값
    return 0.3 + (DateTime.now().millisecondsSinceEpoch % 70) / 100;
  }
}

// MARK: - 녹음 페이지 뷰모델
class RecordingPageViewModel extends BaseViewModel {
  final PermissionUtil _permissionUtil = PermissionUtil();
  final ErrorUtil _errorUtil = ErrorUtil();

  // UseCase 의존성 주입
  final StartRecordUseCase _startRecordUseCase = getIt<StartRecordUseCase>();
  final PauseRecordUseCase _pauseRecordUseCase = getIt<PauseRecordUseCase>();
  final StopRecordUseCase _stopRecordUseCase = getIt<StopRecordUseCase>();

  // 녹음 서비스
  final _recordService = RecordService();

  // 오디오 레벨 (0.0 ~ 1.0)
  List<double> _audioLevels = List.filled(9, 0.3);
  List<double> get audioLevels => _audioLevels;

  // 오디오 레벨 스트림 구독
  StreamSubscription<double>? _audioLevelSubscription;

  // 녹음 상태
  RecordStatus _recordStatus = RecordStatus.NONE;
  RecordStatus get recordStatus => _recordStatus;

  // 녹음 시간 (밀리초)
  int _recordDuration = 0;
  int get recordDuration => _recordDuration;

  // 에러 상태
  bool _hasError = false;
  bool get hasError => _hasError;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // 포맷된 녹음 시간 (mm:ss)
  String get formattedDuration {
    final minutes = (_recordDuration / 60000).floor();
    final seconds = ((_recordDuration % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // 타이머
  Timer? _timer;

  @override
  void clear({bool isInitClear = false}) {
    _stopTimer();
  }

  @override
  Future<void> dataUpdate() async {
    update();
  }

  @override
  Future<void> init() async {
    // 초기 권한 확인
    await _checkPermissions();

    // 오디오 레벨 스트림 구독
    _subscribeToAudioLevels();

    await dataUpdate();
  }

  // 오디오 레벨 업데이트 메서드
  void _updateAudioLevels(double level) {
    Log.d('[RecordingPageViewModel] 오디오 레벨 업데이트: $level');

    // 새로운 오디오 레벨 값들로 업데이트
    _audioLevels = List.generate(9, (index) {
      // 인덱스에 따라 조금씩 다른 높이 (시각적 효과)
      final randomFactor = 0.7 + ((index % 3) * 0.1);
      return (level * randomFactor).clamp(0.05, 1.0);
    });

    // UI 강제 업데이트
    update();
  }

  // 오디오 레벨 스트림 구독
  void _subscribeToAudioLevels() {
    _audioLevelSubscription?.cancel();
    _audioLevelSubscription = _recordService.audioLevelStream.listen(_updateAudioLevels);
    Log.d('[RecordingPageViewModel] 오디오 레벨 스트림 구독 설정 완료');
  }

  // 권한 확인
  Future<bool> _checkPermissions() async {
    try {
      final hasPermissions = await _permissionUtil.requestAllPermissions();

      if (!hasPermissions) {
        _errorUtil.showPermissionError(
          onOpenSettings: () => _permissionUtil.openAppSettings(),
        );
        _setErrorState('녹음을 위한 권한이 필요합니다.');
      } else {
        _clearErrorState();
      }

      return hasPermissions;
    } catch (e, s) {
      _errorUtil.logError(e, s, tag: 'RecordingPageViewModel._checkPermissions');
      _setErrorState('권한 확인 중 오류가 발생했습니다.');
      return false;
    }
  }

  // 에러 상태 설정
  void _setErrorState(String message) {
    _hasError = true;
    _errorMessage = message;
    update();
  }

  // 에러 상태 초기화
  void _clearErrorState() {
    _hasError = false;
    _errorMessage = '';
    update();
  }

  // 녹음 시작/재개
  Future<void> startRecord() async {
    if (_recordStatus == RecordStatus.PLAY) return;

    try {
      final hasPermissions = await _checkPermissions();
      if (!hasPermissions) return;

      // UseCase 호출
      await _startRecordUseCase.call();
      _recordStatus = RecordStatus.PLAY;
      _startTimer();
      _clearErrorState();
      update();
    } catch (e, s) {
      _errorUtil.logError(e, s, tag: 'RecordingPageViewModel.startRecord');
      _setErrorState('녹음을 시작할 수 없습니다.');
      _errorUtil.showError(
        '녹음을 시작할 수 없습니다.',
        onRetry: () => startRecord(),
      );
    }
  }

  // 녹음 일시정지
  Future<void> pauseRecord() async {
    if (_recordStatus != RecordStatus.PLAY) return;

    try {
      // UseCase 호출
      await _pauseRecordUseCase.call();
      _recordStatus = RecordStatus.PAUSE;
      _stopTimer();
      update();
    } catch (e, s) {
      _errorUtil.logError(e, s, tag: 'RecordingPageViewModel.pauseRecord');
      _errorUtil.showError('녹음을 일시정지할 수 없습니다.');
    }
  }

  // 녹음 중지
  Future<void> stopRecord() async {
    if (_recordStatus != RecordStatus.PLAY && _recordStatus != RecordStatus.PAUSE) return;

    try {
      // UseCase 호출
      await _stopRecordUseCase.call();
      _recordStatus = RecordStatus.STOP;
      _stopTimer();
      _recordDuration = 0;
      update();

      // 저장 완료 알림
      Get.snackbar(
        '완료',
        '녹음이 저장되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KwonThemes().primary.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e, s) {
      _errorUtil.logError(e, s, tag: 'RecordingPageViewModel.stopRecord');
      _errorUtil.showError(
        '녹음을 저장할 수 없습니다.',
        onRetry: () => stopRecord(),
      );
    }
  }

  // 녹음 취소
  Future<void> cancelRecord() async {
    if (_recordStatus != RecordStatus.PLAY && _recordStatus != RecordStatus.PAUSE) return;

    _errorUtil.showErrorDialog(
      title: '녹음 취소',
      message: '현재 녹음을 취소하시겠습니까? 녹음된 내용은 저장되지 않습니다.',
      confirmText: '취소하기',
      onConfirm: () async {
        try {
          // 녹음 중지 (저장하지 않음)
          _recordStatus = RecordStatus.STOP;
          _stopTimer();
          _recordDuration = 0;
          update();
        } catch (e, s) {
          _errorUtil.logError(e, s, tag: 'RecordingPageViewModel.cancelRecord');
          _errorUtil.showError('녹음 취소 중 오류가 발생했습니다.');
        }
      },
    );
  }

  // 타이머 시작
  void _startTimer() {
    _stopTimer();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _recordDuration += 100;
      update();
    });
  }

  // 타이머 중지
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void onClose() {
    _stopTimer();
    _audioLevelSubscription?.cancel();
    super.onClose();
  }
}