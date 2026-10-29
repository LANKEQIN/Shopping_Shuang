import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data.dart';
import '../models.dart';

/// 玩法服务：拼团、砍价、抽免单与秒杀预约。
///
/// 玩法自身不直接创建订单，通过 [onGroupSuccess] / [onCutSuccess] 回调
/// 交给上层编排，保证服务边界清晰。
class PlayService extends ChangeNotifier {
  final List<GroupBuy> groupBuys = [];
  CutRecord? cutRecord;
  int cutSuccessCount = 0;

  int lotteryCount = 0;
  int lotteryMissStreak = 0;
  final List<LotteryRecord> lotteryHistory = [];

  final Set<int> seckillReminders = {};

  final Random _rnd = Random();

  Product? Function(int id)? _resolveProduct;
  void Function(Product product, double price)? onGroupSuccess;
  void Function(Product product)? onCutSuccess;

  set productResolver(Product? Function(int id)? resolver) =>
      _resolveProduct = resolver;

  // ---------------- 拼团 ----------------

  GroupBuy startGroup(Product product, {int required = 2}) {
    final now = DateTime.now();
    final group = GroupBuy(
      id: 'GB${now.millisecondsSinceEpoch}',
      productId: product.id,
      required: required,
      members: [GroupMember(name: '幽幽子', emoji: '🌸', isMe: true)],
      createdAt: now,
      endsAt: now.add(const Duration(hours: 24)),
    );
    groupBuys.insert(0, group);
    notifyListeners();
    return group;
  }

  /// 模拟一位好友参团；返回 null 表示好友婉拒。
  GroupMember? inviteGroupFriend(GroupBuy group) {
    if (group.status != GroupStatus.forming) return null;
    if (group.joined >= group.required) return null;
    if (_rnd.nextDouble() < 0.2) return null;
    final friend = playFriends[group.members.length % playFriends.length];
    final member = GroupMember(name: friend.$1, emoji: friend.$2);
    group.members.add(member);
    if (group.members.length >= group.required) {
      group.status = GroupStatus.success;
      final p = _resolveProduct?.call(group.productId);
      if (p != null) {
        onGroupSuccess?.call(p, p.price * 0.88);
      }
    }
    notifyListeners();
    return member;
  }

  void abandonGroup(GroupBuy group) {
    if (group.status != GroupStatus.forming) return;
    group.status = GroupStatus.failed;
    notifyListeners();
  }

  int expireGroups() {
    var count = 0;
    final now = DateTime.now();
    for (final g in groupBuys) {
      if (g.status != GroupStatus.forming) continue;
      if (now.isBefore(g.endsAt)) continue;
      g.status = GroupStatus.failed;
      count++;
    }
    if (count > 0) notifyListeners();
    return count;
  }

  int get groupSuccessCount =>
      groupBuys.where((g) => g.status == GroupStatus.success).length;

  // ---------------- 砍价 ----------------

  CutRecord ensureCutRecord(Product product) {
    final current = cutRecord;
    if (current != null && current.productId == product.id) {
      return current;
    }
    final record = CutRecord(
      productId: product.id,
      original: product.price,
      remaining: product.price,
      cuts: [],
      startedAt: DateTime.now(),
    );
    cutRecord = record;
    notifyListeners();
    return record;
  }

  void resetCutRecord() {
    cutRecord = null;
    notifyListeners();
  }

  /// 砍一刀；剩最后 3 元时保底砍完。
  CutSlice? cutOnce() {
    final record = cutRecord;
    if (record == null || record.done) return null;
    final friend = playFriends[record.cuts.length % playFriends.length];
    var amount = record.original * (0.06 + _rnd.nextDouble() * 0.16);
    if (record.remaining <= 3.0) amount = record.remaining;
    if (amount > record.remaining) amount = record.remaining;
    final slice = CutSlice(
      name: friend.$1,
      emoji: friend.$2,
      amount: amount,
      time: DateTime.now(),
    );
    record.cuts.insert(0, slice);
    record.remaining = (record.remaining - amount).clamp(0.0, record.original);
    if (record.remaining <= 0.011) {
      record.remaining = 0;
      if (!record.done) {
        record.done = true;
        cutSuccessCount++;
        final p = _resolveProduct?.call(record.productId);
        if (p != null) onCutSuccess?.call(p);
      }
    }
    notifyListeners();
    return slice;
  }

  void markCutPoster() {
    final record = cutRecord;
    if (record == null || record.sharedPoster) return;
    record.sharedPoster = true;
    notifyListeners();
  }

  void markCutShownOff() {
    final record = cutRecord;
    if (record == null || record.shownOff) return;
    record.shownOff = true;
    notifyListeners();
  }

  // ---------------- 抽免单 ----------------

  /// 按权重抽奖；连续未中免单达到 [pityLimit] 次时强制返回 [freeIndex]。
  int rollLottery(List<int> weights, int freeIndex, {required int pityLimit}) {
    lotteryCount++;
    if (lotteryMissStreak + 1 >= pityLimit) {
      lotteryMissStreak = 0;
      return freeIndex;
    }
    final total = weights.fold(0, (s, w) => s + w);
    var roll = _rnd.nextInt(total <= 0 ? 1 : total);
    var result = 0;
    for (var i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll < 0) {
        result = i;
        break;
      }
    }
    if (result == freeIndex) {
      lotteryMissStreak = 0;
    } else {
      lotteryMissStreak++;
    }
    return result;
  }

  void recordLottery(LotteryRecord record) {
    lotteryHistory.insert(0, record);
    if (lotteryHistory.length > 30) {
      lotteryHistory.removeRange(30, lotteryHistory.length);
    }
    if (record.free) lotteryMissStreak = 0;
    notifyListeners();
  }

  // ---------------- 秒杀预约 ----------------

  bool isSeckillReserved(int productId) =>
      seckillReminders.contains(productId);

  bool toggleSeckillReminder(int productId) {
    final added = seckillReminders.add(productId);
    if (!added) seckillReminders.remove(productId);
    notifyListeners();
    return added;
  }

  // ---------------- 持久化 ----------------

  Map<String, dynamic> toJson() => {
    'groups': [
      for (final g in groupBuys)
        {
          'id': g.id,
          'pid': g.productId,
          'required': g.required,
          'created': g.createdAt.toIso8601String(),
          'ends': g.endsAt.toIso8601String(),
          'status': g.status.name,
          'members': [
            for (final m in g.members)
              {'name': m.name, 'emoji': m.emoji, 'me': m.isMe},
          ],
        },
    ],
    'cut': cutRecord == null
        ? null
        : {
            'pid': cutRecord!.productId,
            'original': cutRecord!.original,
            'remaining': cutRecord!.remaining,
            'started': cutRecord!.startedAt.toIso8601String(),
            'done': cutRecord!.done,
            'poster': cutRecord!.sharedPoster,
            'shownOff': cutRecord!.shownOff,
            'cuts': [
              for (final c in cutRecord!.cuts)
                {
                  'name': c.name,
                  'emoji': c.emoji,
                  'amount': c.amount,
                  'time': c.time.toIso8601String(),
                },
            ],
          },
    'cutSuccess': cutSuccessCount,
    'lotteryCount': lotteryCount,
    'lotteryMiss': lotteryMissStreak,
    'lotteryHistory': [
      for (final l in lotteryHistory)
        {
          'title': l.title,
          'emoji': l.emoji,
          'note': l.note,
          'time': l.time.toIso8601String(),
          'free': l.free,
          'freeName': l.freeProductName,
        },
    ],
    'seckill': seckillReminders.toList(),
  };

  void restoreFrom(
    Map<String, dynamic> data,
    Product? Function(int id) resolveProduct,
  ) {
    cutSuccessCount = _nonNegativeInt(data['cutSuccess'], 0);
    lotteryCount = _nonNegativeInt(data['lotteryCount'], 0);
    lotteryMissStreak = _nonNegativeInt(data['lotteryMiss'], 0);

    seckillReminders
      ..clear()
      ..addAll(_intSet(data['seckill']));

    groupBuys.clear();
    final groupsRaw = data['groups'];
    if (groupsRaw is List) {
      for (final item in groupsRaw) {
        if (item is! Map) continue;
        final pid = item['pid'];
        if (pid is! num) continue;
        final p = resolveProduct(pid.toInt());
        if (p == null) continue;
        final membersRaw = item['members'];
        if (membersRaw is! List) continue;
        final members = <GroupMember>[];
        for (final m in membersRaw) {
          if (m is! Map) continue;
          members.add(
            GroupMember(
              name: (m['name'] as String?) ?? '好友',
              emoji: (m['emoji'] as String?) ?? '🙂',
              isMe: m['me'] == true,
            ),
          );
        }
        groupBuys.add(
          GroupBuy(
            id: (item['id'] as String?) ?? 'G${groupBuys.length}',
            productId: p.id,
            required: ((item['required'] as num?)?.toInt() ?? 2).clamp(2, 6),
            members: members,
            createdAt: _dateOrNull(item['created']) ?? DateTime.now(),
            endsAt:
                _dateOrNull(item['ends']) ??
                DateTime.now().add(const Duration(hours: 24)),
            status: GroupStatus.values.firstWhere(
              (s) => s.name == item['status'],
              orElse: () => GroupStatus.forming,
            ),
          ),
        );
      }
    }

    cutRecord = null;
    final cutRaw = data['cut'];
    if (cutRaw is Map) {
      final pid = cutRaw['pid'];
      if (pid is num) {
        final p = resolveProduct(pid.toInt());
        if (p != null) {
          final cuts = <CutSlice>[];
          final slicesRaw = cutRaw['cuts'];
          if (slicesRaw is List) {
            for (final c in slicesRaw) {
              if (c is! Map) continue;
              cuts.add(
                CutSlice(
                  name: (c['name'] as String?) ?? '好友',
                  emoji: (c['emoji'] as String?) ?? '🙂',
                  amount: _nonNegativeDouble(c['amount'], 0),
                  time: _dateOrNull(c['time']) ?? DateTime.now(),
                ),
              );
            }
          }
          cutRecord = CutRecord(
            productId: p.id,
            original: _nonNegativeDouble(cutRaw['original'], p.price),
            remaining: _nonNegativeDouble(cutRaw['remaining'], p.price),
            cuts: cuts,
            startedAt: _dateOrNull(cutRaw['started']) ?? DateTime.now(),
            done: cutRaw['done'] == true,
            sharedPoster: cutRaw['poster'] == true,
            shownOff: cutRaw['shownOff'] == true,
          );
        }
      }
    }

    lotteryHistory.clear();
    final lotteryRaw = data['lotteryHistory'];
    if (lotteryRaw is List) {
      for (final item in lotteryRaw) {
        if (item is! Map) continue;
        lotteryHistory.add(
          LotteryRecord(
            title: (item['title'] as String?) ?? '神秘奖品',
            emoji: (item['emoji'] as String?) ?? '🎁',
            note: (item['note'] as String?) ?? '',
            time: _dateOrNull(item['time']) ?? DateTime.now(),
            free: item['free'] == true,
            freeProductName: item['freeName'] as String?,
          ),
        );
      }
    }
  }

  void seed() {
    groupBuys
      ..clear()
      ..add(
        GroupBuy(
          id: 'GB20261026001',
          productId: 55,
          required: 2,
          members: [GroupMember(name: '幽幽子', emoji: '🌸', isMe: true)],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          endsAt: DateTime.now().subtract(const Duration(days: 2)),
          status: GroupStatus.failed,
        ),
      );
    cutRecord = null;
    cutSuccessCount = 0;
    lotteryCount = 0;
    lotteryMissStreak = 0;
    lotteryHistory.clear();
    seckillReminders.clear();
  }

  DateTime? _dateOrNull(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  Set<int> _intSet(Object? value) {
    final set = <int>{};
    if (value is List) {
      for (final v in value) {
        if (v is num) set.add(v.toInt());
      }
    }
    return set;
  }

  int _nonNegativeInt(Object? value, int fallback) {
    final v = (value as num?)?.toInt();
    if (v == null || v < 0) return fallback;
    return v;
  }

  double _nonNegativeDouble(Object? value, double fallback) {
    final v = (value as num?)?.toDouble();
    if (v == null || v.isNaN || v < 0) return fallback;
    return v;
  }
}
