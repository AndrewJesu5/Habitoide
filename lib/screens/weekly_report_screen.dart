// lib/screens/weekly_report_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../habit.dart';
import '../habit_provider.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final allHabits = habitProvider.habits;
    final history = habitProvider.completionHistory;

    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final last7Days = List.generate(7, (i) => today.subtract(Duration(days: i)))
        .reversed
        .toList();

    int totalGoodCompleted = 0;
    int totalBadCompleted = 0;
    Map<String, int> goodHabitCompletionCount = {};
    Map<String, int> badHabitCompletionCount = {};
    Map<int, int> completionsByWeekday = {
      for (var i = 1; i <= 7; i++) i: 0
    };

    for (var habit in allHabits) {
      if (habit.type == HabitType.good) {
        goodHabitCompletionCount[habit.id] = 0;
      } else {
        badHabitCompletionCount[habit.id] = 0;
      }
    }

    final completionsThisWeek = history
        .where((c) => c.date.isAfter(today.subtract(const Duration(days: 7))));

    for (var completion in completionsThisWeek) {
      final habit = allHabits.firstWhere((h) => h.id == completion.habitId,
          orElse: () => Habit(
              id: '',
              name: 'Hábito Removido',
              type: HabitType.good,
              xpYield: 0));
      if (habit.id.isEmpty) {
        continue;
      }

      if (habit.type == HabitType.good) {
        totalGoodCompleted++;
        goodHabitCompletionCount[habit.id] =
            (goodHabitCompletionCount[habit.id] ?? 0) + 1;
        completionsByWeekday[completion.date.weekday] =
            (completionsByWeekday[completion.date.weekday] ?? 0) + 1;
      } else {
        totalBadCompleted++;
        badHabitCompletionCount[habit.id] =
            (badHabitCompletionCount[habit.id] ?? 0) + 1;
      }
    }

    int currentStreak = 0;
    for (int i = 0; i < 365; i++) {
      final dateToCheck = today.subtract(Duration(days: i));
      if (history.any((c) =>
          _isSameDay(c.date, dateToCheck) &&
          allHabits
                  .firstWhere((h) => h.id == c.habitId,
                      orElse: () => Habit(
                          id: '', name: '', type: HabitType.bad, xpYield: 0))
                  .type ==
              HabitType.good)) {
        currentStreak++;
      } else {
        break;
      }
    }

    String bestDay = "N/A";
    if (completionsByWeekday.values.any((count) => count > 0)) {
      final bestDayWeekday = completionsByWeekday.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      final referenceDate = last7Days.firstWhere(
          (d) => d.weekday == bestDayWeekday,
          orElse: () => DateTime.now());
      bestDay = DateFormat('EEEE', 'pt_BR')
          .format(referenceDate)
          .replaceFirstMapped(
              RegExp(r'^\w'), (match) => match[0]!.toUpperCase());
    }

    final sortedGoodHabits = goodHabitCompletionCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedBadHabits = badHabitCompletionCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório Semanal'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: colorScheme.primary,
      ),
      body: allHabits.isEmpty
          ? _buildEmptyState(context, "Sem hábitos para analisar!",
              "Adicione hábitos para começar a ver seus relatórios.")
          : history.isEmpty
              ? _buildEmptyState(context, "Sem dados para a semana!",
                  "Complete alguns hábitos para ver seu progresso aqui.")
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
                  children: [
                    _buildSummaryCard(context, totalGoodCompleted,
                        totalBadCompleted, currentStreak, bestDay),
                    const SizedBox(height: 24),
                    Text('Desempenho Diário (Hábitos Bons)',
                        style: textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(context, last7Days, completionsByWeekday),
                    const SizedBox(height: 24),
                    Text('Análise dos Hábitos', style: textTheme.titleLarge),
                    const SizedBox(height: 16),
                    if (sortedGoodHabits.any((h) => h.value > 0))
                      _buildHabitAnalysisCard(
                        context: context,
                        title: 'Em Destaque',
                        icon: Icons.star_rounded,
                        iconColor: Colors.amber.shade700,
                        habits: sortedGoodHabits
                            .where((h) => h.value > 0)
                            .take(3)
                            .toList(),
                        allHabitsMap: {for (var h in allHabits) h.id: h.name},
                        subtitle: (count) => '$count vezes na semana',
                      ),
                    const SizedBox(height: 12),
                    if (sortedGoodHabits.any((h) => h.value == 0))
                      _buildHabitAnalysisCard(
                        context: context,
                        title: 'Áreas para Melhorar',
                        icon: Icons.lightbulb_outline_rounded,
                        iconColor: Colors.blue.shade600,
                        habits: sortedGoodHabits
                            .where((h) => h.value == 0)
                            .toList(),
                        allHabitsMap: {for (var h in allHabits) h.id: h.name},
                        subtitle: (count) => 'Nenhuma vez esta semana',
                      ),
                    const SizedBox(height: 12),
                    if (sortedBadHabits.any((h) => h.value > 0))
                      _buildHabitAnalysisCard(
                        context: context,
                        title: 'Pontos de Atenção',
                        icon: Icons.warning_amber_rounded,
                        iconColor: Colors.red.shade600,
                        habits:
                            sortedBadHabits.where((h) => h.value > 0).toList(),
                        allHabitsMap: {for (var h in allHabits) h.id: h.name},
                        subtitle: (count) => 'Praticado $count vezes',
                      ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, int good, int bad, int streak, String bestDay) {
    final firstRowItems = [
      _buildStatItem(context, Icons.check_circle,
          Colors.green.shade600, good.toString(), 'Bons Concluídos'),
      _buildStatItem(context, Icons.local_fire_department,
          Colors.orange.shade700, streak.toString(), 'Dias em Sequência'),
    ];

    final secondRowItems = [
      _buildStatItem(context, Icons.emoji_events,
          Colors.purple.shade600, bestDay, 'Melhor Dia'),
      if (bad > 0)
        _buildStatItem(context, Icons.cancel, Colors.red.shade600,
            bad.toString(), 'Ruins Praticados'),
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('Resumo da Semana',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: firstRowItems,
            ),
            const SizedBox(height: 16), 
            Row(
              mainAxisAlignment: bad > 0
                  ? MainAxisAlignment.spaceAround 
                  : MainAxisAlignment.center,     
              children: secondRowItems,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
  
  Widget _buildWeeklyChart(BuildContext context, List<DateTime> last7Days,
      Map<int, int> completionsByWeekday) {
    final theme = Theme.of(context);
    final maxYValue = completionsByWeekday.values.isEmpty
        ? 0
        : completionsByWeekday.values.reduce(math.max);
    final maxY = (maxYValue.toDouble() * 1.2);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 5 : maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final day = last7Days[value.toInt()];
                  return Text(DateFormat('E', 'pt_BR').format(day)[0], style: theme.textTheme.bodySmall);
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() % 2 != 0 && value != 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(value.toInt().toString(), style: theme.textTheme.bodySmall);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withAlpha((0.2 * 255).round()),
                strokeWidth: 1),
          ),
          barGroups: List.generate(7, (i) {
            final day = last7Days[i];
            final count = completionsByWeekday[day.weekday] ?? 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: theme.colorScheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHabitAnalysisCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<MapEntry<String, int>> habits,
    required Map<String, String> allHabitsMap,
    required String Function(int count) subtitle,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            if (habits.isEmpty)
              const Text('Nenhum hábito nesta categoria.',
                  style: TextStyle(color: Colors.grey))
            else
              ...habits.map((entry) {
                final habitName = allHabitsMap[entry.key] ?? 'Hábito Removido';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(habitName,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Text(subtitle(entry.value),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade700)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}