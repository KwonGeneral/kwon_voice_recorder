

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kwon_voice_recorder/common/Scheme.dart';
import 'package:kwon_voice_recorder/common/utils/ErrorUtil.dart';
import 'package:kwon_voice_recorder/data/service/RecordService.dart';
import 'package:kwon_voice_recorder/injection/injection.dart';
import 'package:kwon_voice_recorder/presenter/BaseViewModel.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:kwon_voice_recorder/common/types/RecordStatus.dart';
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:kwon_voice_recorder/domain/model/RecordData.dart';
import 'package:kwon_voice_recorder/domain/usecase/GetHistoryUseCase.dart';
import 'package:kwon_voice_recorder/domain/usecase/PlayHistoryUseCase.dart';
import 'package:kwon_voice_recorder/presenter/route/KwonRouter.dart';
import 'package:kwon_voice_recorder/presenter/style/TextStyles.dart';
import 'package:kwon_voice_recorder/presenter/theme/Themes.dart';

// MARK: - 녹음 기록 재생 페이지
class PlayHistoryPage extends StatelessWidget {
  const PlayHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayHistoryPageViewModel>(
      init: PlayHistoryPageViewModel(),
      builder: (model) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '녹음 재생',
              style: TextStyles.bold(fontSize: 18, color: KwonThemes().surface01),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: KwonThemes().backgroundSub,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: KwonThemes().surface01,
              ),
              onPressed: () {
                // 히스토리 페이지로 명시적 이동
                KwonRouter.to(scheme: Scheme.HISTORY);
              },
            ),
          ),
          body: _buildBody(context, model),
        );
      },
    );
  }

  // 본문 내용 결정
  Widget _buildBody(BuildContext context, PlayHistoryPageViewModel model) {
    if (model.isLoading || model.isInitializing) {
      return _buildLoadingState();
    } else if (model.hasError) {
      return _buildErrorState(model);
    } else if (model.currentRecord == null) {
      return _buildEmptyState();
    } else {
      return _buildPlayerUI(context, model);
    }
  }

  // 로딩 상태 UI
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: KwonThemes().primary,
          ),
          const SizedBox(height: 16),
          Text(
            '녹음 로딩 중...',
            style: TextStyles.medium(
              fontSize: 16,
              color: KwonThemes().black50,
            ),
          ),
        ],
      ),
    );
  }

  // 에러 상태 UI
  Widget _buildErrorState(PlayHistoryPageViewModel model) {
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
            onPressed: () => model.retry(),
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

  // 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.music_off,
            size: 64,
            color: KwonThemes().black30,
          ),
          const SizedBox(height: 16),
          Text(
            '녹음을 찾을 수 없습니다',
            style: TextStyles.medium(
              fontSize: 16,
              color: KwonThemes().black50,
            ),
          ),
        ],
      ),
    );
  }

  // 플레이어 UI
  Widget _buildPlayerUI(BuildContext context, PlayHistoryPageViewModel model) {
    return SafeArea(
      child: Container(
        color: KwonThemes().background,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 녹음 정보
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 오디오 아이콘
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: KwonThemes().primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.music_note,
                            size: 64,
                            color: KwonThemes().primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 파일명
                      Text(
                        model.currentRecord?.fileName ?? '',
                        style: TextStyles.bold(
                          fontSize: 20,
                          color: KwonThemes().surface01,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // 녹음 날짜
                      Text(
                        model.currentRecord?.formattedDate ?? '',
                        style: TextStyles.regular(
                          fontSize: 14,
                          color: KwonThemes().black60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 재생 컨트롤
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // 진행 슬라이더
                    Slider(
                      value: model.playProgress,
                      onChanged: (value) => model.seekToProgress(value),
                      activeColor: KwonThemes().primary,
                      inactiveColor: KwonThemes().black20,
                    ),

                    // 시간 표시
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            model.formattedPosition,
                            style: TextStyles.regular(
                              fontSize: 12,
                              color: KwonThemes().black60,
                            ),
                          ),
                          Text(
                            model.formattedDuration,
                            style: TextStyles.regular(
                              fontSize: 12,
                              color: KwonThemes().black60,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 재생 컨트롤 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 10초 뒤로
                        _buildControlButton(
                          icon: Icons.replay_10,
                          onTap: () {
                            final newPosition = (model.currentPosition - 10000).clamp(0, model.totalDuration);
                            model.seekTo(newPosition);
                          },
                        ),

                        const SizedBox(width: 24),

                        // 재생/일시정지
                        _buildPlayButton(model),

                        const SizedBox(width: 24),

                        // 10초 앞으로
                        _buildControlButton(
                          icon: Icons.forward_10,
                          onTap: () {
                            final newPosition = (model.currentPosition + 10000).clamp(0, model.totalDuration);
                            model.seekTo(newPosition);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 파일 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KwonThemes().backgroundSub,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '파일 정보',
                      style: TextStyles.bold(
                        fontSize: 14,
                        color: KwonThemes().surface01,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.timer,
                      label: '녹음 길이',
                      value: model.formattedDuration,
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      icon: Icons.date_range,
                      label: '녹음 날짜',
                      value: model.currentRecord?.formattedDate ?? '',
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      icon: Icons.storage,
                      label: '파일 크기',
                      value: model.currentRecord?.formattedFileSize ?? '',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: KwonThemes().black50,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyles.medium(
            fontSize: 12,
            color: KwonThemes().black70,
          ),
        ),
        Text(
          value,
          style: TextStyles.regular(
            fontSize: 12,
            color: KwonThemes().black60,
          ),
        ),
      ],
    );
  }

  // 컨트롤 버튼
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: KwonThemes().backgroundSub,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: KwonThemes().primary,
          size: 30,
        ),
      ),
    );
  }

  // 재생 버튼
  Widget _buildPlayButton(PlayHistoryPageViewModel model) {
    final isPlaying = model.playStatus == RecordStatus.PLAY;

    return InkWell(
      onTap: () {
        if (isPlaying) {
          model.pausePlayback();
        } else {
          model.startPlayback();
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: KwonThemes().primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: KwonThemes().primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

// MARK: - 녹음 기록 재생 페이지 뷰모델
class PlayHistoryPageViewModel extends BaseViewModel {
  // UseCase 의존성 주입
  final GetHistoryUseCase _getHistoryUseCase = getIt<GetHistoryUseCase>();
  final PlayHistoryUseCase _playHistoryUseCase = getIt<PlayHistoryUseCase>();

  final ErrorUtil _errorUtil = ErrorUtil();

  // 서비스 인스턴스 (오디오 플레이어 컨트롤을 위해 필요)
  final _recordService = RecordService();

  // 현재 재생 중인 녹음
  RecordData? _currentRecord;
  RecordData? get currentRecord => _currentRecord;

  // 오디오 플레이어
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 초기화 중인지 여부
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  // 오류 상태
  bool _hasError = false;
  bool get hasError => _hasError;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // 재생 상태
  RecordStatus _playStatus = RecordStatus.NONE;
  RecordStatus get playStatus => _playStatus;

  // 재생 위치 (밀리초)
  int _currentPosition = 0;
  int get currentPosition => _currentPosition;

  // 전체 길이 (밀리초)
  int _totalDuration = 0;
  int get totalDuration => _totalDuration;

  // 재생 진행률 (0.0 ~ 1.0)
  double get playProgress {
    if (_totalDuration == 0) return 0;
    return _currentPosition / _totalDuration;
  }

  // 위치 업데이트 타이머
  Timer? _positionTimer;

  // 포맷된 현재 위치 (mm:ss)
  String get formattedPosition {
    final minutes = (_currentPosition / 60000).floor();
    final seconds = ((_currentPosition % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // 포맷된 전체 길이 (mm:ss)
  String get formattedDuration {
    final minutes = (_totalDuration / 60000).floor();
    final seconds = ((_totalDuration % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void clear({bool isInitClear = false}) {
    _stopPositionTimer();
    pausePlayback();
    _hasError = false;
    _errorMessage = '';
    _isLoading = false;
  }

  @override
  Future<void> dataUpdate() async {
    update();
  }

  @override
  Future<void> init() async {
    Log.d('[PlayHistoryPageViewModel] init 시작');
    _isInitializing = true;

    try {
      // 현재 선택된 녹음 ID 가져오기
      final recordId = Get.arguments?['id'];
      Log.d('[PlayHistoryPageViewModel] 전달받은 ID: $recordId, 타입: ${recordId?.runtimeType}');

      if (recordId != null) {
        try {
          await _loadRecordData(recordId.toString());
        } catch (e, s) {
          Log.e('[PlayHistoryPageViewModel] 녹음 데이터 로드 실패: $e', s);
          _hasError = true;
          _errorMessage = '녹음을 찾을 수 없습니다: $e';
          update();
        }
      } else {
        Log.e('[PlayHistoryPageViewModel] ID가 전달되지 않음', StackTrace.current);
        _hasError = true;
        _errorMessage = '녹음 ID가 전달되지 않았습니다';
        update();
        return;
      }

      // 오디오 플레이어 이벤트 리스너
      _setupAudioPlayerListeners();

      await dataUpdate();
      Log.d('[PlayHistoryPageViewModel] init 완료');
    } catch (e, s) {
      Log.e('[PlayHistoryPageViewModel] init 오류: $e', s);
      _hasError = true;
      _errorMessage = '녹음을 불러올 수 없습니다: $e';
    }

    _isInitializing = false;
    update();
  }

  // _loadRecordData 메소드 개선
  Future<void> _loadRecordData(String recordId) async {
    try {
      Log.d('[PlayHistoryPageViewModel] _loadRecordData 호출: ID=$recordId');
      final records = await _getHistoryUseCase.call();
      Log.d('[PlayHistoryPageViewModel] 녹음 목록 조회 결과: ${records.length}개');

      // 직접 탐색 로직 구현
      bool found = false;
      for (var record in records) {
        // ID 값과 타입 출력
        Log.d('[PlayHistoryPageViewModel] 비교: ${record.id}(${record.id.runtimeType}) vs $recordId(${recordId.runtimeType})');

        // 다양한 방법으로 비교 시도
        if (record.id.toString() == recordId.toString()) {
          _currentRecord = record;
          found = true;
          Log.d('[PlayHistoryPageViewModel] ID로 녹음을 찾음: ${record.fileName}');
          break;
        }
        // 파일명으로도 시도
        else if (record.fileName.contains(recordId) ||
            recordId.contains(record.fileName)) {
          _currentRecord = record;
          found = true;
          Log.d('[PlayHistoryPageViewModel] 파일명으로 녹음을 찾음: ${record.fileName}');
          break;
        }
      }

      if (!found) {
        // 정확한 오류 정보
        Log.e('[PlayHistoryPageViewModel] 녹음을 찾을 수 없음: $recordId', StackTrace.current);

        // 가장 최근 녹음으로 대체
        if (records.isNotEmpty) {
          _currentRecord = records.first;
          Log.d('[PlayHistoryPageViewModel] 녹음을 찾지 못해 최근 녹음으로 대체: ${_currentRecord!.fileName}');
        } else {
          throw Exception('녹음을 찾을 수 없습니다: ID=$recordId');
        }
      }

      if (_currentRecord != null) {
        _totalDuration = _currentRecord!.duration;
        update();
        Log.d('[PlayHistoryPageViewModel] 녹음 데이터 로드 성공: ${_currentRecord!.fileName}');
      } else {
        throw Exception('녹음을 찾을 수 없습니다');
      }
    } catch (e, s) {
      Log.e('[PlayHistoryPageViewModel] _loadRecordData 오류: $e', s);
      _errorUtil.logError(e, s, tag: 'PlayHistoryPageViewModel._loadRecordData');
      throw e;
    }
  }

  // 오디오 플레이어 이벤트 설정
  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _playStatus = RecordStatus.PLAY;
        _startPositionTimer();
      } else if (state == PlayerState.paused) {
        _playStatus = RecordStatus.PAUSE;
        _stopPositionTimer();
      } else if (state == PlayerState.completed || state == PlayerState.stopped) {
        _playStatus = RecordStatus.STOP;
        _currentPosition = 0;
        _stopPositionTimer();
      }
      update();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position.inMilliseconds;
      update();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration.inMilliseconds;
      update();
    });

    // 에러 핸들링
    _audioPlayer.onPlayerComplete.listen((_) {
      // 재생 완료 처리
      _playStatus = RecordStatus.STOP;
      _currentPosition = 0;
      update();
    });
  }

  // 재생 시작
  Future<void> startPlayback() async {
    if (_currentRecord == null) return;

    try {
      if (_playStatus == RecordStatus.PAUSE) {
        await _audioPlayer.resume();
      } else {
        await _playHistoryUseCase.call(id: _currentRecord!.id);
        await _audioPlayer.play(DeviceFileSource(_currentRecord!.filePath));
      }

      _playStatus = RecordStatus.PLAY;
      update();
    } catch (e, s) {
      _errorUtil.logError(e, s, tag: 'PlayHistoryPageViewModel.startPlayback');
      _errorUtil.showError('재생을 시작할 수 없습니다.');
    }
  }

  // 재생 일시정지
  Future<void> pausePlayback() async {
    if (_playStatus != RecordStatus.PLAY) return;

    try {
      await _audioPlayer.pause();
      _playStatus = RecordStatus.PAUSE;
      update();
    } catch (e, s) {
      _errorUtil.logError(e, s, tag: 'PlayHistoryPageViewModel.pausePlayback');
      _errorUtil.showError('재생을 일시정지할 수 없습니다.');
    }
  }

  // 재생 중지
  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stop();
      _playStatus = RecordStatus.STOP;
      _currentPosition = 0;
      update();
    } catch (e, s) {
      _errorUtil.logError(e, s, tag: 'PlayHistoryPageViewModel.stopPlayback');
      _errorUtil.showError('재생을 중지할 수 없습니다.');
    }
  }

  // 특정 위치로 이동
  Future<void> seekTo(int position) async {
    try {
      await _audioPlayer.seek(Duration(milliseconds: position));
      _currentPosition = position;
      update();
    } catch (e, s) {
      _errorUtil.logError(e, s, tag: 'PlayHistoryPageViewModel.seekTo');
      _errorUtil.showError('탐색 중 오류가 발생했습니다.');
    }
  }

  // 진행률로 이동 (0.0 ~ 1.0)
  Future<void> seekToProgress(double progress) async {
    if (_totalDuration == 0) return;

    final position = (_totalDuration * progress).toInt();
    await seekTo(position);
  }

  // 위치 업데이트 타이머 시작
  void _startPositionTimer() {
    _stopPositionTimer();

    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (_playStatus == RecordStatus.PLAY) {
        final position = await _audioPlayer.getCurrentPosition();
        if (position != null) {
          _currentPosition = position.inMilliseconds;
          update();
        }
      }
    });
  }

  // 위치 업데이트 타이머 중지
  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  // 다시 시도
  void retry() {
    init();
  }

  @override
  void onClose() {
    _stopPositionTimer();
    _audioPlayer.dispose();
    super.onClose();
  }
}