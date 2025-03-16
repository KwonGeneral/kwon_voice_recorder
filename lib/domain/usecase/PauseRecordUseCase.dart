
import 'package:injectable/injectable.dart';
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart';

// MARK: - 녹음 일시정지 UseCase
@singleton
class PauseRecordUseCase {
  final RecordRepositoryImpl recordRepository;

  PauseRecordUseCase(this.recordRepository);

  Future<void> call() async {
    try {
      return recordRepository.pauseRecord();
    } catch(e, s) {
      return Future.error(e, s);
    }
  }
}