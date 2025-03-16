
// MARK: - 공유 DB
import 'package:kwon_voice_recorder/common/utils/Log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedDb implements SharedDbImpl {
  static const String _MY_INFO = 'my_info';  // 내 정보

  // MARK: - Key값을 미리 로드
  final Map<String, String?> _preloadingKeys = {};

  Future<void> preloading() async {
    _preloadingKeys[_MY_INFO] = await getString(_MY_INFO);
  }

  // MARK: - String 값 저장
  @override
  Future<bool> putString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  // MARK: - String 값 조회
  @override
  Future<String?> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // MARK: - Key 값 삭제
  @override
  Future<bool> remove(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  // MARK: - 모든 값 삭제
  @override
  Future<bool> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  // MARK: - String List 값 조회
  @override
  Future<List<String>> getStringList(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getStringList(key) ?? [];
    Log.d('[SharedDb] getStringList: key=$key, size=${result.length}');
    return result;
  }

  // MARK: - String List 값 저장
  @override
  Future<bool> putStringList(String key, List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Log.d('[SharedDb] putStringList: key=$key, size=${value.length}');
    return await prefs.setStringList(key, value);
  }
}

abstract class SharedDbImpl {
  // MARK: - String 값 저장
  Future<bool> putString(String key, String value);

  // MARK: - String 값 조회
  Future<String?> getString(String key);

  // MARK: - Key 값 삭제
  Future<bool> remove(String key);

  // MARK: - 모든 값 삭제
  Future<bool> clear();

  // MARK: - String List 값 조회
  Future<List<String>> getStringList(String key);

  // MARK: - String List 값 저장
  Future<bool> putStringList(String key, List<String> value);
}