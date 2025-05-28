// Arquivo: lib/screens/mascot_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../habit_provider.dart';

class MascotScreen extends StatelessWidget {
  const MascotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final score = habitProvider.currentScore;
    final mascotState = habitProvider.mascotState;
    final habitsDone = habitProvider.habitsDoneCount;
    final totalHabits = habitProvider.totalHabitsCount;

    String mascotEmoji;
    Color mascotColor;
    String mascotStatusText;

    switch (mascotState) {
      case MascotState.happy:
        mascotEmoji = '😄'; 
        mascotColor = Colors.green.shade600;
        mascotStatusText = 'Estou me sentindo ótimo!';
        break;
      case MascotState.neutral:
        mascotEmoji = '😐'; 
        mascotColor = Colors.orange.shade600;
        mascotStatusText = 'Estou bem, vamos continuar!';
        break;
      case MascotState.sad:
        mascotEmoji = '😟'; 
        mascotColor = Colors.red.shade600;
        mascotStatusText = 'Preciso de mais hábitos bons...';
        break;
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // --- Seção do Mascote ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mascotColor.withOpacity(0.15),
                  border: Border.all(color: mascotColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: mascotColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Text(
                  mascotEmoji,
                  style: TextStyle(fontSize: 100, color: mascotColor),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                mascotStatusText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: mascotColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- Seção de Status (Pontuação e Hábitos) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusCard(
                    context,
                    icon: Icons.star_rounded,
                    label: 'Pontuação',
                    value: score.toStringAsFixed(0),
                    iconColor: Colors.amber.shade700,
                  ),
                  _buildStatusCard(
                    context,
                    icon: Icons.check_circle_rounded,
                    label: 'Hábitos Hoje',
                    value: '$habitsDone/$totalHabits',
                    iconColor: Colors.teal.shade600,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Barra de Progresso da Pontuação
              if (totalHabits > 0)
                Column(
                  children: [
                    Text(
                      'Progresso Diário: ${score.toStringAsFixed(0)} / 100',
                      style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: score / 100, // Valor entre 0.0 e 1.0
                        minHeight: 20,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(mascotColor),
                      ),
                    ),
                  ],
                ),

              const Spacer(),
               Padding(
                 padding: const EdgeInsets.only(bottom: 20.0),
                 child: Text(
                  totalHabits == 0
                      ? 'Adicione hábitos na aba "Hábitos" para começar!'
                      : 'Continue assim, você está indo bem!',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                             ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para criar os cards de status
  Widget _buildStatusCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color
            ),
          ),
        ],
      ),
    );
  }
}