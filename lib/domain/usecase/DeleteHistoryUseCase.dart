
import 'package:injectable/injectable.dart';
import 'package:kwon_voice_recorder/domain/repository/RecordRepositoryImpl.dart';

// MARK: - 녹음 기록 삭제 UseCase
@singleton
class DeleteHistoryUseCase {
  final RecordRepositoryImpl recordRepository;

  DeleteHistoryUseCase(this.recordRepository);

  Future<void> call({required String id}) async {
    try {
      return recordRepository.deleteHistory(id: id);
    } catch(e, s) {
      return Future.error(e, s);
    }
  }
}