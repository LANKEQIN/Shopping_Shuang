import 'package:shared_preferences/shared_preferences.dart';

/// 本地键值存储抽象。
///
/// 上层只依赖该接口，方便在测试中替换为 [MemoryStorage]，
/// 将来也可以无缝替换为文件、SQLite 或加密存储。
abstract class Storage {
  const Storage();

  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> remove(String key);
}

/// 内存实现：用于测试与持久化不可用时的兜底。
class MemoryStorage extends Storage {
  MemoryStorage([Map<String, String>? initial]) : _data = {...?initial};

  final Map<String, String> _data;

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }
}

/// shared_preferences 实现：Android / Web / 桌面均可用（离线）。
class SharedPrefsStorage extends Storage {
  SharedPrefsStorage();

  Future<SharedPreferences>? _prefs;

  Future<SharedPreferences> get _instance =>
      _prefs ??= SharedPreferences.getInstance();

  @override
  Future<String?> read(String key) async {
    try {
      final prefs = await _instance;
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      final prefs = await _instance;
      await prefs.setString(key, value);
    } catch (_) {
      // 持久化失败时静默降级，不阻塞主流程；内存状态仍然可用。
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      final prefs = await _instance;
      await prefs.remove(key);
    } catch (_) {
      // 同上。
    }
  }
}
