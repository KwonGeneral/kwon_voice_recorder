// MARK: - 녹음 Repository
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:kwon_voice_recorder/common/types/RecordStatus.dart';
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:kwon_voice_recorder/data/db/SharedDb.dart';
import 'package:kwon_voice_recorder/data/service/RecordService.dart';
import 'package:kwon_voice_recorder/domain/model/RecordData.dart';
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart';

@Singleton(as: RecordRepositoryImpl)
class RecordRepository implements RecordRepositoryImpl {
  // 서비스 인스턴스
  final _recordService = RecordService();

  // 녹음 내역 저장소 키
  static const String _recordHistoryKey = 'record_history_key';

  // 로컬 DB
  final _sharedDb = SharedDb();

  // 캐시된 녹음 목록
  List<RecordData> _cachedRecordings = [];

  // 초기화 여부
  bool _isInitialized = false;

  // 초기화
  Future<void> _initialize() async {
    if (_isInitialized) return;

    await _loadRecordingsFromDb();
    _isInitialized = true;
  }

  // DB에서 녹음 목록 로드
  Future<void> _loadRecordingsFromDb() async {
    try {
      final jsonList = await _sharedDb.getStringList(_recordHistoryKey);

      if (jsonList.isEmpty) {
        _cachedRecordings = [];
        Log.d('[RecordRepository] 로드된 녹음 목록이 비어 있습니다.');
        return;
      }

      Log.d('[RecordRepository] 녹음 목록 JSON 로드: ${jsonList.length}개');

      try {
        _cachedRecordings = jsonList
            .map((jsonStr) {
          try {
            final decoded = json.decode(jsonStr);
            Log.d('[RecordRepository] JSON 디코딩: $decoded');
            return RecordData.fromJson(decoded);
          } catch (e) {
            Log.e('JSON 디코딩 실패: $e', StackTrace.current);
            throw e;
          }
        })
            .toList();
      } catch (e) {
        Log.e('녹음 목록 파싱 실패: $e', StackTrace.current);
        _cachedRecordings = [];
        throw e;
      }

      // 최신 순으로 정렬
      _cachedRecordings.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

      Log.d('[RecordRepository] 녹음 목록 로드 완료: ${_cachedRecordings.length}개');
      for (int i = 0; i < _cachedRecordings.length; i++) {
        Log.d('[RecordRepository] 녹음[$i]: ${_cachedRecordings[i]}');
      }
    } catch (e) {
      Log.e('녹음 목록 로드 실패: $e', StackTrace.current);
      _cachedRecordings = [];
    }
  }

  // DB에 녹음 목록 저장
  Future<void> _saveRecordingsToDb() async {
    try {
      final jsonList = _cachedRecordings
          .map((recording) => json.encode(recording.toJson()))
          .toList();

      await _sharedDb.putStringList(_recordHistoryKey, jsonList);
      Log.d('[RecordRepository] 녹음 목록 저장 완료: ${jsonList.length}개');
    } catch (e) {
      Log.e('녹음 목록 저장 실패', StackTrace.current);
    }
  }

  // MARK: - 녹음 시작
  @override
  Future<void> startRecord() async {
    await _initialize();
    final recordingPath = await _recordService.startRecording();

    if (recordingPath != null) {
      Log.d('[RecordRepository] 녹음 시작: $recordingPath');
    } else {
      throw Exception('Failed to start recording');
    }
  }

  // MARK: - 녹음 일시정지
  @override
  Future<void> pauseRecord() async {
    await _initialize();
    final success = await _recordService.pauseRecording();

    if (!success) {
      throw Exception('Failed to pause recording');
    }
  }

  // MARK: - 녹음 중지
  @override
  Future<void> stopRecord() async {
    await _initialize();
    final recordingPath = await _recordService.stopRecording();

    if (recordingPath != null) {
      try {
        // 녹음 파일 정보 가져오기
        final recordingInfo = await _recordService.getRecordingInfo(recordingPath);

        if (recordingInfo != null) {
          // 파일명 추출
          final pathParts = recordingPath.split('/');
          final fileName = pathParts.last.split('.').first;

          // 녹음 데이터 생성
          final recordData = RecordData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fileName: fileName,
            filePath: recordingPath,
            recordedAt: DateTime.now(),
            duration: recordingInfo['duration'] ?? 0,
            fileSize: recordingInfo['fileSize']?.toDouble() ?? 0,
            status: RecordStatus.STOP,
          );

          // 저장소에 추가
          _cachedRecordings.insert(0, recordData);
          await _saveRecordingsToDb();

          Log.d('[RecordRepository] 녹음 중지 및 저장: $recordingPath');
        } else {
          Log.e('녹음 정보를 가져올 수 없음', StackTrace.current);
          throw Exception('Failed to get recording info');
        }
      } catch (e, s) {
        Log.e('녹음 저장 실패: $e', s);
        throw Exception('Failed to save recording: $e');
      }
    } else {
      Log.e('녹음 중지 실패: 경로가 null임', StackTrace.current);
      throw Exception('Failed to stop recording: path is null');
    }
  }

  // MARK: - 녹음 기록 조회
  @override
  Future<List<RecordData>> getHistoryList() async {
    await _initialize();
    return _cachedRecordings;
  }

  // MARK: - 녹음 기록 삭제
  @override
  Future<void> deleteHistory({required String id}) async {
    await _initialize();

    final recordIndex = _cachedRecordings.indexWhere((record) => record.id == id);

    if (recordIndex >= 0) {
      final recordData = _cachedRecordings[recordIndex];
      final success = await _recordService.deleteRecording(recordData.filePath);

      if (success) {
        _cachedRecordings.removeAt(recordIndex);
        await _saveRecordingsToDb();
        Log.d('[RecordRepository] 녹음 삭제: $id');
      } else {
        throw Exception('Failed to delete recording file');
      }
    } else {
      throw Exception('Recording not found');
    }
  }

  // MARK: - 녹음 기록 재생
  @override
  Future<void> playHistory({required String id}) async {
    await _initialize();

    final recordData = _cachedRecordings.firstWhere(
          (record) => record.id == id,
      orElse: () => throw Exception('Recording not found'),
    );

    final success = await _recordService.playAudio(recordData.filePath);

    if (!success) {
      throw Exception('Failed to play recording');
    }

    // 상태 업데이트
    final updatedRecordData = RecordData(
      id: recordData.id,
      fileName: recordData.fileName,
      filePath: recordData.filePath,
      recordedAt: recordData.recordedAt,
      duration: recordData.duration,
      fileSize: recordData.fileSize,
      status: RecordStatus.PLAY,
    );

    final index = _cachedRecordings.indexWhere((record) => record.id == id);
    if (index >= 0) {
      _cachedRecordings[index] = updatedRecordData;
      await _saveRecordingsToDb();
    }
  }

  // MARK: - 녹음 기록 파일명 수정
  @override
  Future<void> updateHistoryFileName({required String id, required String fileName}) async {
    await _initialize();

    final recordIndex = _cachedRecordings.indexWhere((record) => record.id == id);

    if (recordIndex >= 0) {
      final recordData = _cachedRecordings[recordIndex];
      final newPath = await _recordService.renameRecording(recordData.filePath, fileName);

      if (newPath != null) {
        // 업데이트된 데이터 생성
        final updatedRecordData = RecordData(
          id: recordData.id,
          fileName: fileName,
          filePath: newPath,
          recordedAt: recordData.recordedAt,
          duration: recordData.duration,
          fileSize: recordData.fileSize,
          status: recordData.status,
        );

        // 저장소 업데이트
        _cachedRecordings[recordIndex] = updatedRecordData;
        await _saveRecordingsToDb();
        Log.d('[RecordRepository] 녹음 파일명 수정: $id -> $fileName');
      } else {
        throw Exception('Failed to rename recording file');
      }
    } else {
      throw Exception('Recording not found');
    }
  }

  // 녹음 기록 재생 중지
  Future<void> stopPlayingHistory() async {
    await _initialize();
    final success = await _recordService.stopAudio();

    if (!success) {
      throw Exception('Failed to stop playing');
    }

    // 모든 녹음 상태 업데이트
    for (int i = 0; i < _cachedRecordings.length; i++) {
      if (_cachedRecordings[i].status == RecordStatus.PLAY) {
        final recordData = _cachedRecordings[i];
        final updatedRecordData = RecordData(
          id: recordData.id,
          fileName: recordData.fileName,
          filePath: recordData.filePath,
          recordedAt: recordData.recordedAt,
          duration: recordData.duration,
          fileSize: recordData.fileSize,
          status: RecordStatus.STOP,
        );

        _cachedRecordings[i] = updatedRecordData;
      }
    }

    await _saveRecordingsToDb();
  }

  // 녹음 기록 재생 일시정지
  Future<void> pausePlayingHistory() async {
    await _initialize();
    final success = await _recordService.pauseAudio();

    if (!success) {
      throw Exception('Failed to pause playing');
    }

    // 재생 중인 녹음 상태 업데이트
    for (int i = 0; i < _cachedRecordings.length; i++) {
      if (_cachedRecordings[i].status == RecordStatus.PLAY) {
        final recordData = _cachedRecordings[i];
        final updatedRecordData = RecordData(
          id: recordData.id,
          fileName: recordData.fileName,
          filePath: recordData.filePath,
          recordedAt: recordData.recordedAt,
          duration: recordData.duration,
          fileSize: recordData.fileSize,
          status: RecordStatus.PAUSE,
        );

        _cachedRecordings[i] = updatedRecordData;
      }
    }

    await _saveRecordingsToDb();
  }
}