import 'dart:developer' as dev;

class AppLogger {
  AppLogger._(this._tag);

  final String _tag;

  static final Map<String, AppLogger> _cache = {};

  static AppLogger get(String tag) {
    return _cache.putIfAbsent(tag, () => AppLogger._(tag));
  }

  void d(String message) {
    dev.log('debug: $message', name: _tag);
  }

  void i(String message) {
    dev.log('info: $message', name: _tag);
  }

  void w(String message) {
    dev.log('warning $message', name: _tag, level: 900);
  }

  void e(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(
      'error: $message',
      name: _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
