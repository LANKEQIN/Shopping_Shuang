import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../fx.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              _card(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '体验反馈',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '动效',
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '加购飞入、撒花、转盘等动画',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: palette.textTertiary,
                        ),
                      ),
                      value: app.animationsEnabled,
                      activeThumbColor: primary,
                      onChanged: (v) {
                        app.setAnimationsEnabled(v);
                        Fx.tap();
                      },
                    ),
                    Divider(height: 1, color: palette.divider),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '触觉反馈',
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '加购、抢购、抽奖时的轻微震动',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: palette.textTertiary,
                        ),
                      ),
                      value: app.hapticsEnabled,
                      activeThumbColor: primary,
                      onChanged: (v) => app.setHapticsEnabled(v),
                    ),
                    Divider(height: 1, color: palette.divider),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '音效',
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '点击与成功时的系统提示音',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: palette.textTertiary,
                        ),
                      ),
                      value: app.soundsEnabled,
                      activeThumbColor: primary,
                      onChanged: (v) => app.setSoundsEnabled(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本地数据',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '购物车、订单、皮肤、搜索历史与优惠券都保存在本机，'
                      '杀掉进程再打开也不会丢。',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.6,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () => _confirmReset(context, app),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(
                            color: primary.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          '清除本地数据，恢复首次启动状态',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _dataCard(context, app),
              const SizedBox(height: 12),
              _card(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '关于',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '爽购 · 解压模拟商城  v1.2.0',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '数据仅保存在本机，不联网、不上报、不产生真实交易。',
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.6,
                        color: palette.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dataCard(BuildContext context, AppState app) {
    final palette = paletteOf(context);
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品数据',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '当前来源：${app.catalogSourceLabel} · ${app.products.length} 件商品。'
            '商品、Banner 与直播间数据来自 JSON 资产，可导出备份或粘贴导入自定义商品包。',
            style: TextStyle(
              fontSize: 10.5,
              height: 1.6,
              color: palette.textTertiary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _miniButton(
                context,
                icon: Icons.ios_share_rounded,
                label: '导出 JSON',
                onTap: () => _exportCatalog(context, app),
              ),
              _miniButton(
                context,
                icon: Icons.file_download_outlined,
                label: '导入 JSON',
                onTap: () => _importCatalog(context, app),
              ),
              _miniButton(
                context,
                icon: Icons.restart_alt_rounded,
                label: '恢复内置',
                onTap: () => _restoreCatalog(context, app),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: primary.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> _exportCatalog(BuildContext context, AppState app) async {
    final palette = paletteOf(context);
    final json = app.exportCatalog();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('导出商品数据'),
        content: SizedBox(
          width: double.maxFinite,
          height: 320,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: TextStyle(
                fontSize: 10,
                height: 1.4,
                color: palette.textSecondary,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              '关闭',
              style: TextStyle(color: palette.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              if (!context.mounted) return;
              showToast(context, '商品数据已复制到剪贴板', icon: Icons.copy_rounded);
            },
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }

  Future<void> _importCatalog(BuildContext context, AppState app) async {
    final palette = paletteOf(context);
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('导入商品数据'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            minLines: 5,
            maxLines: 8,
            style: const TextStyle(fontSize: 11),
            decoration: InputDecoration(
              hintText: '粘贴 catalog.json 内容',
              hintStyle: TextStyle(fontSize: 11, color: palette.textDisabled),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              '取消',
              style: TextStyle(color: palette.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('导入'),
          ),
        ],
      ),
    );
    final raw = controller.text;
    controller.dispose();
    if (confirmed != true || raw.trim().isEmpty) return;
    final result = await app.importCatalog(raw);
    if (!context.mounted) return;
    if (result.ok) {
      showToast(
        context,
        '已导入 ${result.catalog!.products.length} 件商品',
        icon: Icons.check_circle_rounded,
      );
    } else {
      showToast(
        context,
        '导入失败：${result.error}',
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _restoreCatalog(BuildContext context, AppState app) async {
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('恢复内置商品数据？'),
        content: Text(
          '当前导入的自定义商品包会被清除，购物车与订单里已有的商品不会消失。',
          style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              '取消',
              style: TextStyle(color: palette.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('恢复', style: TextStyle(color: primary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await app.restoreBuiltInCatalog();
    if (!context.mounted) return;
    showToast(context, '已恢复内置商品数据', icon: Icons.restart_alt_rounded);
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Material(
      color: paletteOf(context).card,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: child,
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, AppState app) async {
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除本地数据？'),
        content: Text(
          '购物车、订单、皮肤与搜索历史都会恢复到首次启动状态，此操作不可撤销。',
          style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('取消', style: TextStyle(color: palette.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('清除', style: TextStyle(color: primary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await app.resetAll();
    if (!context.mounted) return;
    showToast(context, '已恢复首次启动状态', icon: Icons.restart_alt_rounded);
  }
}
