// MARK: - 녹음 서비스
import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:kwon_voice_recorder/common/types/RecordStatus.dart';
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordService {
  // 싱글톤 인스턴스
  static final RecordService _instance = RecordService._internal();
  factory RecordService() => _instance;
  RecordService._internal();

  // 녹음 인스턴스
  final _audioRecorder = AudioRecorder();

  // 오디오 플레이어 인스턴스
  final _audioPlayer = AudioPlayer();

  // 오디오 레벨 리스너
  final StreamController<double> _audioLevelController = StreamController<double>.broadcast();
  Stream<double> get audioLevelStream => _audioLevelController.stream;

  // 현재 녹음 상태
  RecordStatus _status = RecordStatus.NONE;
  RecordStatus get status => _status;

  // 현재 녹음 중인 파일 경로
  String? _currentRecordingPath;

  // 현재 재생 중인 파일 경로
  String? _currentPlayingPath;

  // 녹음 시간 타이머
  Timer? _recordingTimer;

  // 현재 녹음 시간 (밀리초)
  int _recordingDuration = 0;
  int get recordingDuration => _recordingDuration;

  // 녹음 파일 저장 디렉토리 가져오기
  Future<String> get _recordingDirectory async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final recordingDir = Directory('${appDocDir.path}/recordings');

    if (!await recordingDir.exists()) {
      await recordingDir.create(recursive: true);
    }

    return recordingDir.path;
  }

  // 녹음 시작
  Future<String?> startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (hasPermission) {
      // 이미 녹음 중인 경우
      if (_status == RecordStatus.PLAY) {
        return _currentRecordingPath;
      }

      try {
        // 일시정지 상태였다면 다시 시작
        if (_status == RecordStatus.PAUSE) {
          await _audioRecorder.resume();
          _startTimer();
          _startAudioLevelMonitoring(); // 오디오 레벨 모니터링 시작
          _status = RecordStatus.PLAY;
          return _currentRecordingPath;
        }

        // 새 녹음 시작
        final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final dirPath = await _recordingDirectory;
        _currentRecordingPath = '$dirPath/$fileName';

        final config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await _audioRecorder.start(config, path: _currentRecordingPath!);

        _recordingDuration = 0;
        _startTimer();
        _startAudioLevelMonitoring(); // 오디오 레벨 모니터링 시작
        _status = RecordStatus.PLAY;

        Log.d('[RecordService] 녹음 시작: $_currentRecordingPath');
        return _currentRecordingPath;
      } catch (e) {
        Log.e('녹음 시작 실패', StackTrace.current);
        return null;
      }
    } else {
      Log.e('녹음 권한 없음', StackTrace.current);
      return null;
    }
  }

  // 오디오 레벨 모니터링 시작
  void _startAudioLevelMonitoring() {
    // 주기적으로 진폭 체크
    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (_status != RecordStatus.PLAY) {
        timer.cancel();
        return;
      }

      try {
        final amplitude = await _audioRecorder.getAmplitude();

        // 오디오 레벨 원본 값과 dB 값 모두 로그
        Log.d('[RecordService] 오디오 원본 진폭: ${amplitude.current}, max: ${amplitude.max}, dB: ${amplitude.current}');

        // dB에서 선형 스케일로 변환 (dB은 로그 스케일이라 변환 필요)
        // -160dB (거의 무음) ~ 0dB (최대 볼륨) 범위를 0.05 ~ 1.0 범위로 매핑
        final volume = (amplitude.current + 160) / 160; // -160dB를 0으로, 0dB를 1로 변환
        final normalizedValue = volume.clamp(0.05, 1.0);

        Log.d('[RecordService] 변환된 볼륨: $volume, 정규화 값: $normalizedValue');

        _audioLevelController.add(normalizedValue);
      } catch (e) {
        Log.e('오디오 레벨 모니터링 오류: $e', StackTrace.current);
      }
    });
  }

  // 녹음 일시정지
  Future<bool> pauseRecording() async {
    if (_status != RecordStatus.PLAY) {
      return false;
    }

    try {
      await _audioRecorder.pause();
      _stopTimer();
      _status = RecordStatus.PAUSE;
      Log.d('[RecordService] 녹음 일시정지');
      return true;
    } catch (e) {
      Log.e('녹음 일시정지 실패', StackTrace.current);
      return false;
    }
  }

  // 녹음 중지 및 저장
  Future<String?> stopRecording() async {
    if (_status != RecordStatus.PLAY && _status != RecordStatus.PAUSE) {
      return null;
    }

    try {
      final path = _currentRecordingPath;
      await _audioRecorder.stop();
      _stopTimer();
      _audioLevelController.add(0); // 레벨 0으로 리셋
      _status = RecordStatus.STOP;
      Log.d('[RecordService] 녹음 중지 및 저장: $path');
      return path;
    } catch (e) {
      Log.e('녹음 중지 실패', StackTrace.current);
      return null;
    }
  }

  // 녹음 파일 재생
  Future<bool> playAudio(String filePath) async {
    try {
      if (_status == RecordStatus.PLAY || _status == RecordStatus.PAUSE) {
        await stopRecording();
      }

      // 이미 재생 중인 파일이면 중지
      if (_currentPlayingPath == filePath && _audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
        return true;
      }

      _currentPlayingPath = filePath;
      await _audioPlayer.play(DeviceFileSource(filePath));
      Log.d('[RecordService] 오디오 재생: $filePath');
      return true;
    } catch (e) {
      Log.e('오디오 재생 실패', StackTrace.current);
      return false;
    }
  }

  // 오디오 재생 일시정지
  Future<bool> pauseAudio() async {
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.pause();
        Log.d('[RecordService] 오디오 재생 일시정지');
        return true;
      }
      return false;
    } catch (e) {
      Log.e('오디오 재생 일시정지 실패', StackTrace.current);
      return false;
    }
  }

  // 오디오 재생 중지
  Future<bool> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _currentPlayingPath = null;
      Log.d('[RecordService] 오디오 재생 중지');
      return true;
    } catch (e) {
      Log.e('오디오 재생 중지 실패', StackTrace.current);
      return false;
    }
  }

  // 파일 삭제
  Future<bool> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        if (_currentPlayingPath == filePath) {
          await stopAudio();
        }
        await file.delete();
        Log.d('[RecordService] 녹음 파일 삭제: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      Log.e('녹음 파일 삭제 실패', StackTrace.current);
      return false;
    }
  }

  // 파일 이름 변경
  Future<String?> renameRecording(String filePath, String newName) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final dir = await _recordingDirectory;
        final fileExt = filePath.split('.').last;
        final newPath = '$dir/$newName.$fileExt';
        await file.rename(newPath);

        if (_currentPlayingPath == filePath) {
          _currentPlayingPath = newPath;
        }

        Log.d('[RecordService] 녹음 파일 이름 변경: $filePath -> $newPath');
        return newPath;
      }
      return null;
    } catch (e) {
      Log.e('녹음 파일 이름 변경 실패', StackTrace.current);
      return null;
    }
  }

  // 타이머 시작
  void _startTimer() {
    _stopTimer();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _recordingDuration += 100;
    });
  }

  // 타이머 중지
  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  // 녹음 파일 목록 가져오기
  Future<List<String>> getRecordingFiles() async {
    try {
      final dir = await _recordingDirectory;
      final directory = Directory(dir);
      final List<FileSystemEntity> files = await directory.list().toList();

      // 확장자 필터링
      final recordFiles = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.m4a'))
          .map((file) => file.path)
          .toList();

      return recordFiles;
    } catch (e) {
      Log.e('녹음 파일 목록 가져오기 실패', StackTrace.current);
      return [];
    }
  }

  // 녹음 파일 정보 가져오기 (크기, 길이 등)
  Future<Map<String, dynamic>?> getRecordingInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();

        // 오디오 길이 가져오기 위해 임시로 로드
        final tempPlayer = AudioPlayer();
        await tempPlayer.setSource(DeviceFileSource(filePath));
        await tempPlayer.seek(Duration.zero); // 처음으로 이동
        final duration = await tempPlayer.getDuration() ?? const Duration();
        await tempPlayer.dispose();

        return {
          'fileSize': fileSize,
          'duration': duration.inMilliseconds,
        };
      }
      return null;
    } catch (e) {
      Log.e('녹음 파일 정보 가져오기 실패', StackTrace.current);
      return null;
    }
  }

  // 리소스 해제
  Future<void> dispose() async {
    _stopTimer();
    await _audioRecorder.dispose();
    await _audioPlayer.dispose();
    await _audioLevelController.close();
  }
}