// lib/screens/main_tabs_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../habit_provider.dart';
import 'mascot_screen.dart';
import 'habits_list_screen.dart';
import 'weekly_report_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPageIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'page': const MascotScreen(),
      'title': 'Habitóide',
      'icon': Icons.home_rounded,
      'activeIcon': Icons.home_filled,
    },
    {
      'page': const HabitsListScreen(),
      'title': 'Meus Hábitos',
      'icon': Icons.checklist_rtl_rounded,
      'activeIcon': Icons.checklist_rtl_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging || _tabController.index != _selectedPageIndex) {
      if (mounted) {
        setState(() {
          _selectedPageIndex = _tabController.index;
        });
      }
    }
  }

  void _showResetDialog(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.nightlight_round, color: colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Iniciar Novo Dia?'),
          ],
        ),
        content: const Text(
            'Isso irá desmarcar todos os hábitos para que você possa começar um novo ciclo. Sua pontuação será mantida. Continuar?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colorScheme.onSurface.withAlpha((0.7 * 255).round())),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: () {
              habitProvider.resetDailyHabits();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Um novo dia começou! Boa sorte com seus hábitos!'),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                ),
              );
            },
            child: const Text('Sim, Novo Dia!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedPageIndex]['title'] as String),
        actions: [
          // Ícones que só aparecem na aba de Hábitos
          if (_selectedPageIndex == 1) ...[
            // NOVO: Ícone do Relatório
            Tooltip(
              message: 'Relatório Semanal',
              child: IconButton(
                icon: Icon(Icons.bar_chart_rounded, color: colorScheme.primary),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const WeeklyReportScreen()),
                  );
                },
              ),
            ),
            // Ícone de Reset Diário
            Tooltip(
              message: 'Iniciar Novo Dia',
              child: IconButton(
                icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
                onPressed: () => _showResetDialog(context),
              ),
            ),
          ],
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _pages.map((pageData) => pageData['page'] as Widget).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          _tabController.animateTo(index);
        },
        items: _pages.map((pageData) {
          bool isSelected = _pages.indexOf(pageData) == _selectedPageIndex;
          return BottomNavigationBarItem(
            icon: Icon(pageData[isSelected ? 'activeIcon' : 'icon'] as IconData),
            label: pageData['title'] as String,
          );
        }).toList(),
      ),
    );
  }
}