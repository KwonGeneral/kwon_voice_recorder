

import 'package:kwon_voice_recorder/domain/model/RecordData.dart';


// MARK: - 녹음 Impl
abstract class RecordRepositoryImpl {
  // MARK: - 녹음 시작
  Future<void> startRecord();

  // MARK: - 녹음 일시정지
  Future<void> pauseRecord();

  // MARK: - 녹음 중지
  Future<void> stopRecord();

  // MARK: - 녹음 기록 조회
  Future<List<RecordData>> getHistoryList();

  // MARK: - 녹음 기록 삭제
  Future<void> deleteHistory({required String id});

  // MARK: - 녹음 기록 재생
  Future<void> playHistory({required String id});

  // MARK: - 녹음 기록 파일명 수정
  Future<void> updateHistoryFileName({required String id, required String fileName});
}