import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../log.dart';
import '../storage.dart';

/// 应用本地状态仓库：负责单一键的读写、schema 版本与迁移。
///
/// 键名固定为 [storageKey]，版本号写在 JSON 内部；各业务服务只负责
/// 自己的字段序列化，仓库不感知购物车、订单等业务语义。
@immutable
class AppRepository {
  const AppRepository(this._storage);

  static const String storageKey = 'shuang.app.state';
  static const int schemaVersion = 2;

  final Storage _storage;

  /// 读取并执行版本迁移；无数据、损坏或结构异常时返回 null，由上层回退种子数据。
  Future<Map<String, dynamic>?> read() async {
    String? raw;
    try {
      raw = await _storage.read(storageKey);
    } catch (e) {
      AppLog.warn('读取本地状态失败', e);
      return null;
    }
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        AppLog.warn('本地状态不是 JSON 对象，回退默认数据');
        return null;
      }
      final data = _migrate(Map<String, dynamic>.from(decoded));
      AppLog.info('本地状态读取成功，版本 ${data['version']}');
      return data;
    } catch (e) {
      AppLog.warn('本地状态损坏，回退默认数据', e);
      return null;
    }
  }

  Future<void> write(Map<String, dynamic> snapshot) async {
    try {
      await _storage.write(storageKey, jsonEncode(snapshot));
    } catch (e) {
      // 写入失败不阻塞 UI，内存状态仍然可用。
      AppLog.warn('写入本地状态失败', e);
    }
  }

  Future<void> clear() async {
    try {
      await _storage.remove(storageKey);
    } catch (e) {
      AppLog.warn('清除本地状态失败', e);
    }
  }

  /// 版本迁移入口：旧版本数据在这里补齐字段，未知字段忽略。
  Map<String, dynamic> _migrate(Map<String, dynamic> raw) {
    var data = Map<String, dynamic>.from(raw);
    final version = (data['version'] as num?)?.toInt() ?? 0;
    if (version < 1) {
      // v0（无版本号的早期数据）：仅保留能识别的字段，其余走默认值。
      data = {
        'version': 1,
        if (data['skin'] != null) 'skin': data['skin'],
        if (data['cart'] != null) 'cart': data['cart'],
        if (data['orders'] != null) 'orders': data['orders'],
        if (data['history'] != null) 'history': data['history'],
        if (data['coupons'] != null) 'coupons': data['coupons'],
        if (data['coins'] != null) 'coins': data['coins'],
        if (data['balance'] != null) 'balance': data['balance'],
        if (data['nickname'] != null) 'nickname': data['nickname'],
        if (data['followedLive'] != null) 'followedLive': data['followedLive'],
      };
    }
    if ((data['version'] as num?)?.toInt() == 1) {
      // v1 → v2：结构未变，只是新增玩法字段；由各服务补默认值。
      data['version'] = 2;
    }
    return data;
  }
}
