import 'package:flutter/material.dart';

enum Skin { taobao, jd, pdd, douyin }

class SkinConfig {
  const SkinConfig({
    required this.id,
    required this.name,
    required this.brand,
    required this.slogan,
    required this.searchHint,
    required this.emoji,
    required this.primary,
    required this.accent,
    required this.headerGradient,
    required this.priceColor,
    required this.navBg,
    required this.navFg,
    this.darkHeader = false,
  });

  final Skin id;
  final String name;
  final String brand;
  final String slogan;
  final String searchHint;
  final String emoji;
  final Color primary;
  final Color accent;
  final List<Color> headerGradient;
  final Color priceColor;
  final Color navBg;
  final Color navFg;
  final bool darkHeader;

  bool get dark => darkHeader;
}

const Map<Skin, SkinConfig> kSkins = {
  Skin.taobao: SkinConfig(
    id: Skin.taobao,
    name: '淘宝',
    brand: '爽购淘',
    slogan: '解压购物 · 随便买不要钱',
    searchHint: '搜索：解压捏捏乐 / 电子木鱼',
    emoji: '🧧',
    primary: Color(0xFFFF5000),
    accent: Color(0xFFFFB800),
    headerGradient: [Color(0xFFFF8A00), Color(0xFFFF3D00)],
    priceColor: Color(0xFFFF3D00),
    navBg: Colors.white,
    navFg: Color(0xFF9A9A9A),
  ),
  Skin.jd: SkinConfig(
    id: Skin.jd,
    name: '京东',
    brand: '爽购京',
    slogan: '自营解压 · 快得不像话',
    searchHint: '搜索：自营好物 / 次日达快乐',
    emoji: '🐶',
    primary: Color(0xFFE1251B),
    accent: Color(0xFFFF9F00),
    headerGradient: [Color(0xFFE1251B), Color(0xFFFF5A3C)],
    priceColor: Color(0xFFE1251B),
    navBg: Colors.white,
    navFg: Color(0xFF9A9A9A),
  ),
  Skin.pdd: SkinConfig(
    id: Skin.pdd,
    name: '拼多多',
    brand: '爽购拼',
    slogan: '拼着买 · 更便宜 · 反正不付钱',
    searchHint: '搜索：9.9包邮 / 百亿补贴',
    emoji: '🍑',
    primary: Color(0xFFE02E24),
    accent: Color(0xFFFF6B35),
    headerGradient: [Color(0xFFFF6B4A), Color(0xFFE0211A)],
    priceColor: Color(0xFFE02E24),
    navBg: Colors.white,
    navFg: Color(0xFF9A9A9A),
  ),
  Skin.douyin: SkinConfig(
    id: Skin.douyin,
    name: '抖音',
    brand: '爽购抖',
    slogan: '刷着刷着 · 就买了',
    searchHint: '搜索：直播间同款 / 达人推荐',
    emoji: '🎵',
    primary: Color(0xFFFE2C55),
    accent: Color(0xFF25F4EE),
    headerGradient: [Color(0xFF101014), Color(0xFF262633)],
    priceColor: Color(0xFFFE2C55),
    navBg: Color(0xFF121218),
    navFg: Color(0xFF8A8A96),
    darkHeader: true,
  ),
};

SkinConfig skinOf(Skin skin) => kSkins[skin]!;

/// 随皮肤切换的界面调色板。
///
/// 页面只依赖这里的语义色，不再硬编码白底 / 黑字，
/// 抖音皮肤下自动切换为暗色表面。
@immutable
class SkinPalette extends ThemeExtension<SkinPalette> {
  const SkinPalette({
    required this.pageBg,
    required this.card,
    required this.cardAlt,
    required this.fill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.divider,
    required this.border,
    required this.icon,
    required this.iconDisabled,
    required this.inverseText,
    required this.dark,
  });

  final Color pageBg;
  final Color card;
  final Color cardAlt;
  final Color fill;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color divider;
  final Color border;
  final Color icon;
  final Color iconDisabled;
  final Color inverseText;
  final bool dark;

  static const SkinPalette light = SkinPalette(
    pageBg: Color(0xFFF4F4F6),
    card: Colors.white,
    cardAlt: Color(0xFFF7F7F9),
    fill: Color(0xFFF4F4F6),
    textPrimary: Color(0xFF222222),
    textSecondary: Color(0xFF666666),
    textTertiary: Color(0xFF999999),
    textDisabled: Color(0xFFAAAAAA),
    divider: Color(0xFFF2F2F2),
    border: Color(0xFFE8E8E8),
    icon: Color(0xFF555555),
    iconDisabled: Color(0xFFCCCCCC),
    inverseText: Colors.white,
    dark: false,
  );

  static const SkinPalette darkPalette = SkinPalette(
    pageBg: Color(0xFF0E0E14),
    card: Color(0xFF17171F),
    cardAlt: Color(0xFF20202A),
    fill: Color(0xFF262631),
    textPrimary: Color(0xFFF2F2F5),
    textSecondary: Color(0xFFB9B9C4),
    textTertiary: Color(0xFF8A8A96),
    textDisabled: Color(0xFF6B6B78),
    divider: Color(0xFF2A2A36),
    border: Color(0xFF30303C),
    icon: Color(0xFFC5C5CF),
    iconDisabled: Color(0xFF55555F),
    inverseText: Colors.white,
    dark: true,
  );

  static SkinPalette of(BuildContext context) =>
      Theme.of(context).extension<SkinPalette>() ?? light;

  @override
  SkinPalette copyWith({
    Color? pageBg,
    Color? card,
    Color? cardAlt,
    Color? fill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? divider,
    Color? border,
    Color? icon,
    Color? iconDisabled,
    Color? inverseText,
    bool? dark,
  }) {
    return SkinPalette(
      pageBg: pageBg ?? this.pageBg,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      fill: fill ?? this.fill,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      icon: icon ?? this.icon,
      iconDisabled: iconDisabled ?? this.iconDisabled,
      inverseText: inverseText ?? this.inverseText,
      dark: dark ?? this.dark,
    );
  }

  @override
  SkinPalette lerp(ThemeExtension<SkinPalette>? other, double t) {
    if (other is! SkinPalette) return this;
    return SkinPalette(
      pageBg: Color.lerp(pageBg, other.pageBg, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      iconDisabled: Color.lerp(iconDisabled, other.iconDisabled, t)!,
      inverseText: Color.lerp(inverseText, other.inverseText, t)!,
      dark: t < 0.5 ? dark : other.dark,
    );
  }
}

SkinPalette paletteOf(BuildContext context) => SkinPalette.of(context);

ThemeData buildAppTheme(Skin skin) {
  final cfg = skinOf(skin);
  final palette = cfg.dark ? SkinPalette.darkPalette : SkinPalette.light;
  final brightness = cfg.dark ? Brightness.dark : Brightness.light;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: cfg.primary,
        brightness: brightness,
      ).copyWith(
        primary: cfg.primary,
        secondary: cfg.accent,
        surface: palette.card,
        onSurface: palette.textPrimary,
        outline: palette.border,
        surfaceContainerHighest: palette.cardAlt,
      );
  final baseText = ThemeData(brightness: brightness).textTheme
      .apply(bodyColor: palette.textPrimary, displayColor: palette.textPrimary);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.pageBg,
    cardColor: palette.card,
    dividerColor: palette.divider,
    textTheme: baseText,
    iconTheme: IconThemeData(color: palette.icon),
    appBarTheme: AppBarTheme(
      backgroundColor: cfg.dark ? const Color(0xFF16161C) : palette.card,
      foregroundColor: palette.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.card,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: palette.card,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.card,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      contentTextStyle: TextStyle(
        fontSize: 12,
        height: 1.6,
        color: palette.textSecondary,
      ),
    ),
    dividerTheme: DividerThemeData(color: palette.divider, thickness: 1),
    extensions: [palette],
    splashFactory: InkSparkle.splashFactory,
  );
}
