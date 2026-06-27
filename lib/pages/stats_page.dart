import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';

class StatsPage extends StatefulWidget {
  final VoidCallback? onNavigateToWriting;
  final VoidCallback? onNavigateToFiles;
  final VoidCallback? onNavigateToMaterials;
  final VoidCallback? onNavigateToSettings;

  const StatsPage({
    super.key,
    this.onNavigateToWriting, this.onNavigateToFiles,
    this.onNavigateToMaterials, this.onNavigateToSettings,
  });

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // ── Interactive state ──
  int _timeIndex = 0;   // 0=日, 1=周, 2=月, 3=年
  int _metricIndex = 0; // 0=字数, 1=时长

  // ── Mock data: 4 time periods × 2 metrics ──
  // _allTrends[timeIndex][metricIndex] = list of 7 data points (0.0-1.0)
  late final List<List<List<double>>> _allTrends;
  late final List<List<List<double>>> _allBars;
  late final List<double> _heatData;

  List<double> get _trendData => _allTrends[_timeIndex][_metricIndex];
  List<double> get _barData => _allBars[_timeIndex][_metricIndex];

  static const _metricUnits = ['字', '小时'];

  String get _dateRange => switch (_timeIndex) {
    0 => '2024年3月27日',
    1 => '2024年3月21日 - 2024年3月27日',
    2 => '2024年3月',
    _ => '2024年',
  };

  String get _statValue {
    // Vary stat card values by time × metric
    const vals = [
      ['124.8k', '128.3k', '492.1k', '1.56M'], // 字数-日/周/月/年
      ['4.2', '28.5', '116', '1,240'],          // 时长-日/周/月/年
    ];
    return vals[_metricIndex][_timeIndex];
  }

  String get _statUnit => _metricUnits[_metricIndex];

  @override
  void initState() {
    super.initState();
    final rng = Random(42);
    // Generate data for 4 time periods × 2 metrics
    _allTrends = List.generate(4, (t) => List.generate(2, (m) {
      final base = m == 0 ? 0.15 : 0.1; // words vs hours
      final scale = m == 0 ? 0.7 : 0.8;
      return List.generate(7, (_) => base + rng.nextDouble() * scale);
    }));
    _allBars = List.generate(4, (t) => List.generate(2, (m) {
      final base = m == 0 ? 0.15 : 0.1;
      final scale = m == 0 ? 0.75 : 0.8;
      return List.generate(7, (_) => base + rng.nextDouble() * scale);
    }));
    _heatData = List.generate(140, (_) => rng.nextDouble());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(children: [
        if (isDesktop) AppSidebar(
          currentRoute: 'stats',
          onNavigateToWriting: widget.onNavigateToWriting,
          onNavigateToFiles: widget.onNavigateToFiles,
          onNavigateToMaterials: widget.onNavigateToMaterials,
          onNavigateToSettings: widget.onNavigateToSettings,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.containerMaxWidth),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildStatCards(),
                  const SizedBox(height: 32),
                  _buildControls(),
                  const SizedBox(height: 32),
                  LayoutBuilder(builder: (ctx, constraints) {
                    final wide = constraints.maxWidth > 800;
                    if (wide) {
                      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 2, child: _buildLeftColumn()),
                        const SizedBox(width: 32),
                        Expanded(flex: 1, child: _buildRightColumn()),
                      ]);
                    } else {
                      return Column(children: [_buildLeftColumn(), const SizedBox(height: 32), _buildRightColumn()]);
                    }
                  }),
                ]),
              ),
            ),
          ),
        ),
        if (!isDesktop) _buildMobileNav(),
      ]),
    );
  }

  Widget _buildHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('统计', style: TextStyle(fontFamily: 'Manrope', fontSize: 40,
          fontWeight: FontWeight.w700, height: 48 / 40, letterSpacing: -0.8, color: AppColors.onBackground)),
      const SizedBox(height: 4),
      Text('回顾你的创作历程与产出效率',
          style: TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.onSurfaceVariant.withAlpha(180))),
    ]);
  }

  // ── Stat cards ──
  Widget _buildStatCards() {
    final cards = [
      (_metricIndex == 0 ? '总字数' : '累计时长', _statValue, _statUnit, _metricIndex == 0 ? Icons.text_fields : Icons.timer),
      ('总作品数', '12', '部', Icons.menu_book),
      ('连续创作天数', '24', '天', Icons.whatshot),
      (_metricIndex == 1 ? '总字数' : '累计创作时长', _metricIndex == 1 ? '124.8k' : '316', _metricIndex == 1 ? '字' : '小时', _metricIndex == 1 ? Icons.text_fields : Icons.timer),
    ];
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3),
      itemCount: 4,
      itemBuilder: (_, i) {
        final (label, value, unit, icon) = cards[i];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.outlineVariant)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  letterSpacing: 0.6, color: AppColors.onSurfaceVariant)),
              Icon(icon, size: 20, color: AppColors.outline),
            ]),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(value, style: const TextStyle(fontFamily: 'Manrope', fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(width: 4),
              Padding(padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit, style: const TextStyle(fontSize: 15, color: AppColors.secondary))),
            ]),
          ]),
        );
      },
    );
  }

  // ── Controls (interactive) ──
  Widget _buildControls() {
    return Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.outlineVariant)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Text('全部作品', style: TextStyle(fontSize: 15, color: AppColors.onSurface)),
          SizedBox(width: 8),
          Icon(Icons.expand_more, size: 18, color: AppColors.onSurfaceVariant),
        ]),
      ),
      _switcher(['日', '周', '月', '年'], _timeIndex, (i) => setState(() => _timeIndex = i)),
      const SizedBox(width: 8),
      _switcher(['字数', '时长'], _metricIndex, (i) => setState(() => _metricIndex = i)),
    ]);
  }

  Widget _switcher(List<String> labels, int active, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(mainAxisSize: MainAxisSize.min,
        children: labels.asMap().entries.map((e) {
          final sel = e.key == active;
          return GestureDetector(
            onTap: () => onChanged(e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? AppColors.surfaceContainerLowest : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.normal),
                boxShadow: sel ? [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 2, offset: const Offset(0, 1))] : null,
              ),
              child: Text(e.value, style: TextStyle(fontSize: 15,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                  color: sel ? AppColors.primary : AppColors.onSurfaceVariant)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Left: trend + heatmap ──
  Widget _buildLeftColumn() {
    return Column(children: [
      _buildTrendChart(),
      const SizedBox(height: 32),
      _buildHeatmap(),
    ]);
  }

  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('写作趋势', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          Text(_dateRange, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ]),
        const SizedBox(height: 24),
        SizedBox(height: 200, child: CustomPaint(
          painter: _TrendChartPainter(data: _trendData),
          size: const Size(double.infinity, 200),
        )),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
              .map((d) => Text(d, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant))).toList()),
      ]),
    );
  }

  Widget _buildHeatmap() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('创作热力图', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          Row(children: [
            const Text('少', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            const SizedBox(width: 4),
            Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(1), color: AppColors.surfaceContainer)),
              const SizedBox(width: 2),
              Container(width: 10, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(1), color: AppColors.secondary.withAlpha(80))),
              const SizedBox(width: 2),
              Container(width: 10, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(1), color: AppColors.secondary.withAlpha(160))),
              const SizedBox(width: 2),
              Container(width: 10, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(1), color: AppColors.secondary)),
            ]),
            const SizedBox(width: 4),
            const Text('多', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
          ]),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 3, runSpacing: 3,
          children: _heatData.map((v) => Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: v > 0.7 ? AppColors.secondary
                  : v > 0.4 ? AppColors.secondary.withAlpha(80)
                  : AppColors.surfaceContainer,
            ),
          )).toList()),
      ]),
    );
  }

  // ── Right: activity + rankings ──
  Widget _buildRightColumn() {
    return Column(children: [
      _buildActivityChart(),
      const SizedBox(height: 32),
      _buildRankings(),
    ]);
  }

  Widget _buildActivityChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('近期活跃度', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 24),
        SizedBox(height: 150,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final h = 120 * _barData[i];
              final idx = 21 + i;
              return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  width: 28,
                  height: max(h, 4),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.normal)),
                    color: AppColors.secondary.withAlpha(80 + (_barData[i] * 150).round()),
                  ),
                ),
                const SizedBox(height: 8),
                Text('3.$idx', style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              ]);
            }),
          ),
        ),
      ]),
    );
  }

  Widget _buildRankings() {
    const items = [
      ('荒原上的灯塔', '54,203', 0.85),
      ('未尽之夏', '32,112', 0.60),
      ('硅基漫游指南', '12,890', 0.35),
      ('夜航日记', '8,450', 0.20),
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('作品排行榜', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 24),
        ...items.asMap().entries.map((e) {
          final idx = e.key;
          final (name, words, pct) = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(children: [
              Container(width: 24, height: 24, alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: idx == 0 ? AppColors.primary : AppColors.surfaceContainerHighest),
                child: Text('${idx + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: idx == 0 ? Colors.white : AppColors.onSurfaceVariant))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Container(height: 6, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(3)),
                  child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: pct,
                    child: Container(decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(3))))),
              ])),
              const SizedBox(width: 12),
              Text(words, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          );
        }),
        const Divider(color: AppColors.outlineVariant),
        Center(child: TextButton(
          onPressed: () {},
          child: const Text('查看全部榜单', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
        )),
      ]),
    );
  }

  // ── Mobile nav ──
  Widget _buildMobileNav() {
    return Container(height: 64,
      decoration: BoxDecoration(color: AppColors.background,
        border: const Border(top: BorderSide(color: AppColors.outlineVariant)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 16, offset: const Offset(0, -2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _mobItem(Icons.edit, '写作', false, widget.onNavigateToWriting),
        _mobItem(Icons.folder, '文件', false, widget.onNavigateToFiles),
        _mobItem(Icons.inventory_2, '素材', false, widget.onNavigateToMaterials),
        _mobItem(Icons.insights, '统计', true, null),
        _mobItem(Icons.settings, '设置', false, widget.onNavigateToSettings),
      ]));
  }

  Widget _mobItem(IconData icon, String label, bool active, VoidCallback? onTap) => InkWell(onTap: onTap,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 22, color: active ? AppColors.primary : AppColors.onSurfaceVariant),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? AppColors.primary : AppColors.onSurfaceVariant)),
    ]));
}

// ── Custom Painter (stable data, no Random) ──
class _TrendChartPainter extends CustomPainter {
  final List<double> data;
  _TrendChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const padL = 40.0, padR = 8.0, padT = 8.0, padB = 20.0;
    final cw = (w - padL - padR) / 6;
    final ch = h - padT - padB;

    final points = List.generate(7, (i) {
      final x = padL + i * cw;
      final y = padT + ch * (1 - data[i]);
      return Offset(x, y);
    });

    // Area fill
    final areaPath = Path();
    areaPath.moveTo(points.first.dx, padT + ch);
    for (final p in points) { areaPath.lineTo(p.dx, p.dy); }
    areaPath.lineTo(points.last.dx, padT + ch);
    areaPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [AppColors.primaryContainer.withAlpha(40), AppColors.primaryContainer.withAlpha(0)],
    );
    canvas.drawPath(areaPath, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, padT, w, ch)));

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = padT + ch * i / 4;
      canvas.drawLine(Offset(padL, y), Offset(w - padR, y),
          Paint()..color = AppColors.outlineVariant.withAlpha(30)..strokeWidth = 0.5);
    }

    // Smooth line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset(points[i].dx + cw / 3, points[i].dy);
      final cp2 = Offset(points[i + 1].dx - cw / 3, points[i + 1].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }
    canvas.drawPath(linePath, Paint()
      ..color = AppColors.secondary..strokeWidth = 2
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Data points
    for (final p in points) {
      canvas.drawCircle(p, 3, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3, Paint()..color = AppColors.secondary..style = PaintingStyle.stroke..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) => oldDelegate.data != data;
}
