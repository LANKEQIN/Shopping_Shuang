import 'package:flutter/material.dart';

import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/pieces.dart';

/// 退款售后与发票记录。
class AfterSalePage extends StatefulWidget {
  const AfterSalePage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<AfterSalePage> createState() => _AfterSalePageState();
}

class _AfterSalePageState extends State<AfterSalePage> {
  late int _tab = widget.initialTab.clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    final app = AppState.instance;
    final palette = paletteOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('退款/售后')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          return Column(
            children: [
              Container(
                color: palette.card,
                child: Row(
                  children: [
                    for (var i = 0; i < 2; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _tab = i),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Text(
                                  i == 0
                                      ? '售后记录 ${app.afterSales.length}'
                                      : '发票记录 ${app.invoices.length}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: _tab == i
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: _tab == i
                                        ? primary
                                        : palette.textSecondary,
                                  ),
                                ),
                              ),
                              Container(
                                width: _tab == i ? 24 : 0,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _tab == 0
                    ? _afterSales(context, app, primary)
                    : _invoices(context, app, primary),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _afterSales(BuildContext context, AppState app, Color primary) {
    final palette = paletteOf(context);
    if (app.afterSales.isEmpty) {
      return _empty(
        context,
        '🧾',
        '还没有售后记录',
        '在订单页点「申请退款」，就能体验模拟售后',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
      itemCount: app.afterSales.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final r = app.afterSales[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      r.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: r.status == AfterSaleStatus.done
                          ? palette.cardAlt
                          : primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      r.status.label,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: r.status == AfterSaleStatus.done
                            ? palette.textTertiary
                            : primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '${r.type} · ${r.reason} · 订单 ${r.orderId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '退款金额 ',
                    style: TextStyle(fontSize: 10, color: palette.textSecondary),
                  ),
                  PriceText(r.amount, size: 14, color: primary),
                  const Spacer(),
                  if (r.status == AfterSaleStatus.processing)
                    GestureDetector(
                      onTap: () {
                        app.completeAfterSale(r);
                        showToast(context, '售后已处理完成（模拟）');
                      },
                      child: Container(
                        height: 27,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          '催处理',
                          style: TextStyle(fontSize: 10, color: primary),
                        ),
                      ),
                    )
                  else
                    Text(
                      '退款已到账',
                      style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _invoices(BuildContext context, AppState app, Color primary) {
    final palette = paletteOf(context);
    if (app.invoices.isEmpty) {
      return _empty(
        context,
        '🧾',
        '还没有发票记录',
        '在已完成订单里点「发票」，可申请模拟电子发票',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
      itemCount: app.invoices.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final r = app.invoices[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      r.title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    r.type,
                    style: TextStyle(fontSize: 9.5, color: primary),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '订单 ${r.orderId} · ${r.email}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '开票金额 ',
                    style: TextStyle(fontSize: 10, color: palette.textSecondary),
                  ),
                  PriceText(r.amount, size: 14, color: primary),
                  const Spacer(),
                  Text(
                    '已开具（模拟）',
                    style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context, String emoji, String title, String sub) {
    final palette = paletteOf(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: palette.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
