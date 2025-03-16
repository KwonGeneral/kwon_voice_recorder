
import 'package:injectable/injectable.dart';
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart';

// MARK: - 녹음 기록 이름 변경 UseCase
@singleton
class UpdateHistoryNameUseCase {
  final RecordRepositoryImpl recordRepository;

  UpdateHistoryNameUseCase(this.recordRepository);

  Future<void> call({required String id, required String fileName}) async {
    try {
      return recordRepository.updateHistoryFileName(id: id, fileName: fileName);
    } catch(e, s) {
      return Future.error(e, s);
    }
  }
}