// lib/screens/habits_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../habit_provider.dart';
import '../habit.dart';

class HabitsListScreen extends StatefulWidget {
  const HabitsListScreen({super.key});

  @override
  State<HabitsListScreen> createState() => _HabitsListScreenState();
}

class _HabitsListScreenState extends State<HabitsListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitNameController = TextEditingController();
  HabitType _selectedHabitType = HabitType.good;

  @override
  void dispose() {
    _habitNameController.dispose();
    super.dispose();
  }

  void _resetAddHabitForm() {
    _habitNameController.clear();
    if (mounted) {
      setState(() {
        _selectedHabitType = HabitType.good;
      });
    }
  }

  void _showAddHabitDialog(BuildContext context) {
    _resetAddHabitForm();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.add_task_rounded, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  const Text('Criar Novo Hábito'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _habitNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Hábito',
                          hintText: 'Ex: Ler por 30 min',
                          prefixIcon: Icon(Icons.label_outline_rounded),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira um nome para o hábito.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<HabitType>(
                        value: _selectedHabitType,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Hábito',
                          prefixIcon: Icon(_selectedHabitType == HabitType.good
                              ? Icons.sentiment_very_satisfied_rounded
                              : Icons.sentiment_very_dissatisfied_rounded,
                            color: _selectedHabitType == HabitType.good ? Colors.green : Colors.red,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                          ),
                        ),
                        items: HabitType.values.map((HabitType type) {
                          return DropdownMenuItem<HabitType>(
                            value: type,
                            child: Text(
                              type == HabitType.good ? 'Hábito Bom' : 'Hábito Ruim',
                              style: TextStyle(color: type == HabitType.good ? Colors.green.shade700 : Colors.red.shade700),
                            ),
                          );
                        }).toList(),
                        onChanged: (HabitType? newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              _selectedHabitType = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: colorScheme.onSurface.withAlpha((0.7 * 255).round())),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final habitName = _habitNameController.text.trim();
                      Provider.of<HabitProvider>(context, listen: false)
                          .addHabit(habitName, _selectedHabitType);
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hábito "$habitName" adicionado!'),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(10),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Salvar Hábito'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showRemoveHabitDialog(BuildContext context, Habit habit, HabitProvider habitProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red.shade600),
            const SizedBox(width: 10),
            const Text('Remover Hábito?'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).dialogTheme.contentTextStyle,
            children: [
              const TextSpan(text: 'Tem certeza que deseja remover o hábito permanentemente?\n\n"'),
              TextSpan(text: habit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '"\n\nEsta ação não pode ser desfeita.'),
            ]
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colorScheme.onSurface.withAlpha((0.7 * 255).round())),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white),
            onPressed: () {
              String habitName = habit.name;
              habitProvider.removeHabit(habit.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hábito "$habitName" removido.'),
                  backgroundColor: Colors.orange.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                ),
              );
            },
            icon: const Icon(Icons.delete_sweep_rounded),
            label: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final allHabits = habitProvider.habits;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final goodHabits = allHabits.where((h) => h.type == HabitType.good).toList();
    final badHabits = allHabits.where((h) => h.type == HabitType.bad).toList();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suas Tarefas Diárias',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary
                  ),
                ),
                Chip(
                  avatar: Icon(Icons.pie_chart_outline_rounded, color: colorScheme.onPrimaryContainer, size: 18),
                  label: Text(
                    '${habitProvider.goodHabitsDoneCount}/${habitProvider.totalGoodHabitsCount} Bons',
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: allHabits.isEmpty
                ? _buildEmptyState()
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (goodHabits.isNotEmpty) _buildHabitSection('Hábitos Positivos', goodHabits, habitProvider, Colors.green.shade700),
                      if (badHabits.isNotEmpty) _buildHabitSection('Hábitos a Evitar', badHabits, habitProvider, Colors.red.shade600),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        tooltip: 'Adicionar Novo Hábito',
        icon: const Icon(Icons.add_rounded),
        label: const Text("Novo Hábito"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.space_dashboard_outlined, size: 80, color: Theme.of(context).colorScheme.primary.withAlpha((0.5 * 255).round())),
            const SizedBox(height: 20),
            Text(
              'Sua lista de hábitos está vazia!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.8 * 255).round())),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Clique no botão "+" abaixo para adicionar seu primeiro hábito e começar a construir uma rotina incrível.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round())),
            ),
          ],
        ),
      ));
  }

  Widget _buildHabitSection(String title, List<Habit> sectionHabits, HabitProvider habitProvider, Color titleColor) {
    final textTheme = Theme.of(context).textTheme;
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(title, style: textTheme.titleMedium?.copyWith(color: titleColor, fontWeight: FontWeight.bold)),
        ),
        ...sectionHabits.map((habit) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildHabitItem(habit, habitProvider),
            )),
      ]),
    );
  }

  Widget _buildHabitItem(Habit habit, HabitProvider habitProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    bool isGoodHabit = habit.type == HabitType.good;
    Color habitColor = isGoodHabit ? Colors.green.shade600 : Colors.red.shade500;

    String subtitleText = isGoodHabit ? 'Hábito Bom' : 'Hábito Ruim';
    IconData subtitleIcon = isGoodHabit ? Icons.add_reaction_outlined : Icons.mood_bad_outlined;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        leading: Checkbox(
          value: habit.isDoneToday,
          onChanged: (bool? value) {
            habitProvider.toggleHabitStatus(habit.id);
          },
          activeColor: habitColor,
        ),
        title: Text(
          habit.name,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            decoration: habit.isDoneToday && isGoodHabit
                ? TextDecoration.lineThrough
                : null,
            decorationColor: habitColor.withAlpha((0.7 * 255).round()),
            decorationThickness: 1.5,
            color: habit.isDoneToday && isGoodHabit
                ? colorScheme.onSurface.withAlpha((0.5 * 255).round())
                : colorScheme.onSurface,
          ),
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(subtitleIcon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              subtitleText,
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded,
              color: colorScheme.error.withAlpha((0.7 * 255).round()), size: 26),
          tooltip: 'Remover hábito',
          onPressed: () => _showRemoveHabitDialog(context, habit, habitProvider),
        ),
        onTap: () {
           habitProvider.toggleHabitStatus(habit.id);
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(color: habitColor.withAlpha(habit.isDoneToday ? (0.3*255).round() : (0.6*255).round() ), width: habit.isDoneToday ? 1:2),
        ),
      ),
    );
  }
}