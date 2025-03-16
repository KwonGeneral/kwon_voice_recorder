
import 'package:injectable/injectable.dart';
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart';

// MARK: - 녹음 기록 재생 UseCase
@singleton
class PlayHistoryUseCase {
  final RecordRepositoryImpl recordRepository;

  PlayHistoryUseCase(this.recordRepository);

  Future<void> call({required String id}) async {
    try {
      return recordRepository.playHistory(id: id);
    } catch(e, s) {
      return Future.error(e, s);
    }
  }
}