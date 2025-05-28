// Arquivo: lib/screens/main_tabs_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../habit_provider.dart'; 
import 'mascot_screen.dart';    
import 'habits_list_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {
        _selectedPageIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Dia?'),
        content:
            const Text('Isso irá resetar o progresso dos hábitos para um novo dia. Continuar?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Sim, Novo Dia!'),
            onPressed: () {
              Provider.of<HabitProvider>(context, listen: false)
                  .resetDailyHabits();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Um novo dia começou! Boa sorte com seus hábitos!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> pages = [
      {
        'page': const MascotScreen(),
        'title': 'Meu Habitóide',
      },
      {
        'page': const HabitsListScreen(),
        'title': 'Meus Hábitos',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pages[_selectedPageIndex]['title'] as String),
        actions: [
          IconButton(
            icon: const Icon(Icons.nightlight_round), 
            tooltip: 'Iniciar Novo Dia',
            onPressed: () => _showResetDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: pages.map((page) => page['page'] as Widget).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _tabController.animateTo(index);
        },
        currentIndex: _selectedPageIndex,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled), 
            label: 'Mascote',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Hábitos',
          ),
        ],
      ),
    );
  }
}