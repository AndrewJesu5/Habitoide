// lib/screens/mascot_screen.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../habit_provider.dart';
import '../flame_mascot/mascot_game.dart';

class MascotScreen extends StatefulWidget {
  const MascotScreen({super.key});

  @override
  State<MascotScreen> createState() => _MascotScreenState();
}

class _MascotScreenState extends State<MascotScreen> {
  // Estado para controlar a visibilidade dos textos nas barras de informação
  bool _showXpDetails = false;
  bool _showGoodHabitsCount = false;
  bool _showBadHabitsCount = false;

  late MascotGame _mascotGame;

  @override
  void initState() {
    super.initState();
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    _mascotGame = MascotGame(habitProvider: habitProvider);
  }

  // Widget auxiliar para criar os itens interativos da barra superior
  Widget _buildTopBarInteractiveItem({
    required IconData itemIcon,
    required Color iconColor,
    String? primaryText,
    String? secondaryText,
    required bool showPrimaryText,
    required VoidCallback onTapCallback,
    Widget? progress,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapCallback,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: progress != null ? 6.0 : 8.0,
            vertical: 4.0
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(itemIcon, color: iconColor, size: 18),
              if (showPrimaryText && primaryText != null) ...[
                const SizedBox(width: 4),
                Text(
                  primaryText,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (secondaryText != null)
                  Text(
                    secondaryText,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                    ),
                  ),
              ],
              if (progress != null) ...[
                if (!showPrimaryText) const SizedBox(width: 4),
                if (showPrimaryText) const SizedBox(width: 6),
                progress,
              ]
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[ 
                  SizedBox(
                    width: MascotCharacter.characterDisplaySize.x,
                    height: MascotCharacter.characterDisplaySize.y,
                    child: GameWidget(
                      game: _mascotGame,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // O Consumer reconstrói apenas as barras de informação quando os dados do HabitProvider mudam.
          Consumer<HabitProvider>(
            builder: (context, habitProvider, _) {
              final currentLevel = habitProvider.currentLevel;
              final currentXp = habitProvider.currentXp;
              final xpToNextLevel = habitProvider.xpToNextLevel;
              final goodHabitsDone = habitProvider.goodHabitsDoneCount;
              final totalGoodHabits = habitProvider.totalGoodHabitsCount;
              final badHabitsDone = habitProvider.badHabitsDoneCount;
              final totalBadHabits = habitProvider.totalBadHabitsCount;

              // Dados de tema e cores
              final colorScheme = Theme.of(context).colorScheme;
              const Color xpBarColor = Colors.deepPurpleAccent;
              final Color xpBarBackgroundColor = Colors.deepPurple.shade100.withAlpha((0.4 * 255).round());

              // Retorna um Stack para posicionar as barras sobre a tela principal
              return Stack(
                children: [
                  // Barra de Nível/XP no canto superior esquerdo
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    child: Material(
                      color: colorScheme.surface.withAlpha(220),
                      borderRadius: BorderRadius.circular(12),
                      elevation: 3.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        child: _buildTopBarInteractiveItem(
                          itemIcon: Icons.military_tech_rounded,
                          iconColor: xpBarColor,
                          primaryText: 'Nível $currentLevel',
                          secondaryText: _showXpDetails ? ' (${currentXp.toInt()} XP)' : null,
                          showPrimaryText: true,
                          onTapCallback: () { setState(() { _showXpDetails = !_showXpDetails; }); },
                          progress: SizedBox(
                            width: _showXpDetails ? 70 : 80, height: 8,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (xpToNextLevel > 0) ? (currentXp / xpToNextLevel) : 0,
                                backgroundColor: xpBarBackgroundColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(xpBarColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Contadores de Hábitos no canto superior direito
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (totalGoodHabits > 0)
                          _buildTopBarInteractiveItem(
                            itemIcon: Icons.check_circle_rounded, iconColor: Colors.green.shade600,
                            primaryText: _showGoodHabitsCount ? '$goodHabitsDone/$totalGoodHabits' : null,
                            showPrimaryText: _showGoodHabitsCount,
                            onTapCallback: () { setState(() { _showGoodHabitsCount = !_showGoodHabitsCount; }); },
                          ),
                        if (totalGoodHabits > 0 && totalBadHabits > 0) const SizedBox(height: 4),
                        if (totalBadHabits > 0)
                          _buildTopBarInteractiveItem(
                            itemIcon: Icons.cancel_rounded, iconColor: Colors.red.shade600,
                            primaryText: _showBadHabitsCount ? '$badHabitsDone' : null,
                            showPrimaryText: _showBadHabitsCount,
                            onTapCallback: () { setState(() { _showBadHabitsCount = !_showBadHabitsCount; }); },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}