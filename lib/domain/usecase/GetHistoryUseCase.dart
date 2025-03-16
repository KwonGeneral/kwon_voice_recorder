

import 'package:injectable/injectable.dart';
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:kwon_voice_recorder/domain/model/RecordData.dart';
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart';

// MARK: - 녹음 기록 조회 UseCase
@singleton
class GetHistoryUseCase {
  final RecordRepositoryImpl recordRepository;

  GetHistoryUseCase(this.recordRepository);

  Future<List<RecordData>> call() async {
    try {
      Log.d('[GetHistoryUseCase] 호출됨');
      final result = await recordRepository.getHistoryList();
      Log.d('[GetHistoryUseCase] 결과 반환, 개수: ${result.length}');

      // 결과가 비어있는지 확인
      if (result.isEmpty) {
        Log.d('[GetHistoryUseCase] 결과가 비어 있습니다.');
      } else {
        // 첫 번째 항목 로깅
        Log.d('[GetHistoryUseCase] 첫 번째 항목: ${result.first}');
      }

      return result;
    } catch(e, s) {
      Log.e('[GetHistoryUseCase] 오류 발생: $e', s);
      return Future.error(e, s);
    }
  }
}