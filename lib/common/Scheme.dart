
// MARK: - 스킴
enum Scheme {
  // MARK: - 녹음
  RECORDING("/recording"),

  // MARK: - 히스토리
  HISTORY("/history"),

  // MARK: - 녹음 기록 재생
  PLAY_HISTORY("/play_history");

  final String path;

  const Scheme(this.path);
}