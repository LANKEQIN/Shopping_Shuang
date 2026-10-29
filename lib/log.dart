import 'dart:collection';

import 'package:flutter/foundation.dart';

enum LogLevel {
  debug(0, 'DEBUG'),
  info(1, 'INFO'),
  warn(2, 'WARN'),
  error(3, 'ERROR');

  const LogLevel(this.weight, this.label);

  final int weight;
  final String label;
}

class LogEntry {
  const LogEntry({
    required this.time,
    required this.level,
    required this.message,
    this.error,
  });

  final DateTime time;
  final LogLevel level;
  final String message;
  final Object? error;

  @override
  String toString() {
    final tail = error == null ? '' : ' | $error';
    return '${time.toIso8601String()} [${level.label}] $message$tail';
  }
}

/// 本地日志分级。
///
/// 只保留最近 200 条在内存中，供调试页或问题反馈时读取；
/// 不上传、不联网、不集成任何崩溃监控 SDK（需显式开启的联网能力一律不做）。
/// 应用层通过 [enabled] 与 [minLevel] 控制输出，默认为开启的 info 级别。
class AppLog {
  AppLog._();

  static bool enabled = true;
  static LogLevel minLevel = LogLevel.info;
  static const int maxEntries = 200;

  static final Queue<LogEntry> _recent = Queue<LogEntry>();

  static List<LogEntry> get recent => List.unmodifiable(_recent);

  static void debug(String message, [Object? error]) =>
      _write(LogLevel.debug, message, error);

  static void info(String message, [Object? error]) =>
      _write(LogLevel.info, message, error);

  static void warn(String message, [Object? error]) =>
      _write(LogLevel.warn, message, error);

  static void error(String message, [Object? error]) =>
      _write(LogLevel.error, message, error);

  static void clear() => _recent.clear();

  static void _write(LogLevel level, String message, Object? error) {
    if (!enabled || level.weight < minLevel.weight) return;
    final entry = LogEntry(
      time: DateTime.now(),
      level: level,
      message: message,
      error: error,
    );
    _recent.add(entry);
    while (_recent.length > maxEntries) {
      _recent.removeFirst();
    }
    if (kDebugMode) {
      debugPrint('$entry');
    }
  }
}
