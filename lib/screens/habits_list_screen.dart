// Arquivo: lib/screens/habits_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../habit_provider.dart';
import '../habit.dart';

class HabitsListScreen extends StatelessWidget {
  const HabitsListScreen({super.key});

  void _showAddHabitDialog(BuildContext context) {
    final TextEditingController habitNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Hábito'),
        content: TextField(
          controller: habitNameController,
          decoration: const InputDecoration(
            labelText: 'Nome do Hábito',
            hintText: 'Ex: Ler por 30 min',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Adicionar'),
            onPressed: () {
              final habitName = habitNameController.text.trim();
              if (habitName.isNotEmpty) {
                Provider.of<HabitProvider>(context, listen: false)
                    .addHabit(habitName);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hábito "$habitName" adicionado!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, insira um nome para o hábito.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showRemoveHabitDialog(BuildContext context, Habit habit, HabitProvider habitProvider) {
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Hábito?'),
        content:
            Text('Tem certeza que deseja remover o hábito "${habit.name}"? Esta ação não pode ser desfeita.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('Remover'),
            onPressed: () {
              String habitName = habit.name;
              habitProvider.removeHabit(habit.id);
              Navigator.of(ctx).pop();
               ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hábito "$habitName" removido.'),
                    backgroundColor: Colors.orange,
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
    final habitProvider = Provider.of<HabitProvider>(context);
    final habits = habitProvider.habits;

    return Scaffold(
      body: Column(
        children: <Widget>[
          // --- Cabeçalho da Lista de Hábitos ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tarefas do Dia',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColorDark
                  ),
                ),
                Chip(
                  label: Text(
                    '${habitProvider.habitsDoneCount}/${habitProvider.totalHabitsCount}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                )
              ],
            ),
          ),

          // --- Lista de Hábitos ---
          Expanded(
            child: habits.isEmpty
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.checklist_rtl_rounded, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum hábito para hoje!\nAdicione um novo hábito clicando no botão "+" abaixo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 17, color: Colors.grey),
                        ),
                      ],
                    ),
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 0, bottom: 80), 
                    itemCount: habits.length,
                    itemBuilder: (ctx, index) {
                      final habit = habits[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Checkbox(
                            value: habit.isDoneToday,
                            onChanged: (bool? value) {
                              habitProvider.toggleHabitStatus(habit.id);
                            },
                          ),
                          title: Text(
                            habit.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  decoration: habit.isDoneToday
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: habit.isDoneToday
                                      ? Colors.grey.shade600
                                      : Theme.of(context).textTheme.titleLarge?.color,
                                  fontWeight: FontWeight.w500
                                ),
                          ),
                          subtitle: Text(
                            'Vale: ${habit.points.toStringAsFixed(1)} pts',
                            style: TextStyle(
                                color: habit.isDoneToday
                                    ? Colors.grey
                                    : Colors.blueGrey.shade400,
                                fontSize: 13
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_sweep_outlined,
                                color: Colors.red.shade400, size: 28),
                            tooltip: 'Remover hábito',
                            onPressed: () => _showRemoveHabitDialog(context, habit, habitProvider),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        tooltip: 'Adicionar Novo Hábito',
        icon: const Icon(Icons.add_task_rounded),
        label: const Text("Novo Hábito"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}