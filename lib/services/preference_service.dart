import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// 皮肤、体验开关与搜索历史。
class PreferenceService extends ChangeNotifier {
  final ValueNotifier<Skin> skinNotifier = ValueNotifier<Skin>(Skin.taobao);
  final List<String> searchHistory = ['解压捏捏乐', '电子木鱼', '辣条'];

  bool animationsEnabled = true;
  bool hapticsEnabled = true;
  bool soundsEnabled = true;

  Skin get skin => skinNotifier.value;

  void setSkin(Skin value) {
    if (skin == value) return;
    skinNotifier.value = value;
    notifyListeners();
  }

  void setAnimationsEnabled(bool value) {
    if (animationsEnabled == value) return;
    animationsEnabled = value;
    notifyListeners();
  }

  void setHapticsEnabled(bool value) {
    if (hapticsEnabled == value) return;
    hapticsEnabled = value;
    notifyListeners();
  }

  void setSoundsEnabled(bool value) {
    if (soundsEnabled == value) return;
    soundsEnabled = value;
    notifyListeners();
  }

  void pushHistory(String keyword) {
    if (keyword.trim().isEmpty) return;
    searchHistory.remove(keyword);
    searchHistory.insert(0, keyword);
    if (searchHistory.length > 8) searchHistory.removeLast();
    notifyListeners();
  }

  void clearHistory() {
    searchHistory.clear();
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
    'skin': skin.name,
    'history': searchHistory,
    'settings': {
      'animations': animationsEnabled,
      'haptics': hapticsEnabled,
      'sounds': soundsEnabled,
    },
  };

  void restoreFrom(Map<String, dynamic> data) {
    final skinName = data['skin'];
    skinNotifier.value = Skin.values.firstWhere(
      (s) => s.name == skinName,
      orElse: () => Skin.taobao,
    );

    searchHistory.clear();
    final historyRaw = data['history'];
    if (historyRaw is List) {
      for (final h in historyRaw) {
        if (h is String && h.trim().isNotEmpty) searchHistory.add(h);
      }
    }
    if (searchHistory.length > 8) {
      searchHistory.removeRange(8, searchHistory.length);
    }

    final settings = data['settings'];
    final settingsMap = settings is Map
        ? Map<String, dynamic>.from(settings)
        : const <String, dynamic>{};
    animationsEnabled = settingsMap['animations'] != false;
    hapticsEnabled = settingsMap['haptics'] != false;
    soundsEnabled = settingsMap['sounds'] != false;
  }

  void seed() {
    skinNotifier.value = Skin.taobao;
    searchHistory
      ..clear()
      ..addAll(['解压捏捏乐', '电子木鱼', '辣条']);
    animationsEnabled = true;
    hapticsEnabled = true;
    soundsEnabled = true;
  }
}
