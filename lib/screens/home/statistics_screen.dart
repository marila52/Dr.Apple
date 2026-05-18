import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dr_apple/theme/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/weight_entry_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../services/weight_history_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/spiral_loader.dart';
import '../../widgets/app_back_header.dart';

enum _WeightPeriod { week, month, all }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final WeightHistoryService _weightService = WeightHistoryService();

  List<WeightEntry> _allEntries = [];
  bool _loading = true;
  _WeightPeriod _period = _WeightPeriod.month;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<CustomAuthProvider>();
    final userId = auth.user?.uid;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    final profile = context.read<UserDataProvider>().currentUser;
    final history = await _weightService.ensureInitialFromProfile(
      userId: userId,
      currentWeight: profile?.weight,
    );

    if (!mounted) return;
    setState(() {
      _allEntries = history;
      _loading = false;
    });
  }

  List<WeightEntry> get _filteredEntries {
    if (_period == _WeightPeriod.all || _allEntries.isEmpty) {
      return _allEntries;
    }

    final now = DateTime.now();
    final days = _period == _WeightPeriod.week ? 7 : 30;
    final from = now.subtract(Duration(days: days));

    return _allEntries
        .where((e) => !e.recordedAt.isBefore(from))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBackHeader(title: 'Статистика'),
            Expanded(
              child: _loading
                  ? const Center(child: SpiralLoader(size: 64))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Статистика',
                            style: AppFonts.roboto(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Динамика веса',
                            style: AppFonts.roboto(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPeriodSelector(),
                          const SizedBox(height: 20),
                          _buildWeightChartCard(),
                          const SizedBox(height: 20),
                          _buildSummaryRow(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _periodChip('Неделя', _WeightPeriod.week),
        const SizedBox(width: 8),
        _periodChip('Месяц', _WeightPeriod.month),
        const SizedBox(width: 8),
        _periodChip('Всё', _WeightPeriod.all),
      ],
    );
  }

  Widget _periodChip(String label, _WeightPeriod period) {
    final selected = _period == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _period = period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.cardFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChartCard() {
    final entries = _filteredEntries;

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.spiralPink.withValues(alpha: 0.6)),
      ),
      child: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Пока нет данных о весе.\nЗавершите онбординг или обновите профиль.',
                  textAlign: TextAlign.center,
                  style: AppFonts.roboto(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          : LineChart(_chartData(entries)),
    );
  }

  LineChartData _chartData(List<WeightEntry> entries) {
    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].weight));
    }

    final weights = entries.map((e) => e.weight).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final padding = ((maxW - minW) * 0.15).clamp(1.0, 5.0);

    return LineChartData(
      minY: (minW - padding).floor().toDouble(),
      maxY: (maxW + padding).ceil().toDouble(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColors.border.withValues(alpha: 0.35),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: AppFonts.robotoMono(
                fontSize: 11,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: entries.length > 6 ? (entries.length / 4).ceilToDouble() : 1,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= entries.length) {
                return const SizedBox.shrink();
              }
              final d = entries[i].recordedAt;
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${d.day}.${d.month.toString().padLeft(2, '0')}',
                  style: AppFonts.robotoMono(
                    fontSize: 10,
                    color: AppColors.primaryDark,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.25,
          color: AppColors.spiralPink,
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 4,
              color: AppColors.white,
              strokeWidth: 2,
              strokeColor: AppColors.spiralPink,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.spiralPink.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    final entries = _filteredEntries;
    if (entries.isEmpty) return const SizedBox.shrink();

    final first = entries.first.weight;
    final last = entries.last.weight;
    final delta = last - first;

    return Row(
      children: [
        Expanded(child: _summaryTile('Текущий', '${last.toStringAsFixed(1)} кг')),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryTile(
            'Изменение',
            '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} кг',
          ),
        ),
      ],
    );
  }

  Widget _summaryTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.roboto(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppFonts.robotoMono(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

}
