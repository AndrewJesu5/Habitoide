// lib/screens/outfit_store_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../habit_provider.dart';

class OutfitStoreScreen extends StatelessWidget {
  const OutfitStoreScreen({super.key});

  final Map<String, String> availableOutfits = const {
    'roupa.png': 'Roupa Padrão',
    'aang.png': 'Último mestre do ar',
    'fino.png': 'Fino, senhores',
    'kratos.png': 'Fantasma de Esparta',
    'kuririn.png': 'Kuririn',
    'link.png': 'Esse não é o Zelda',
    'magoo.png': 'Mr. Magoo',
    'mario.png': 'Super Mario',
    'naruto.png': 'Naruto',
    'natal.png': 'Vlw natalina',
    'popeye.png': 'Popeye',
    'walter.png': 'Heisenberg',
  };

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja de Trajes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.8, 
        ),
        itemCount: availableOutfits.length,
        itemBuilder: (context, index) {
          final String outfitAsset = availableOutfits.keys.elementAt(index);
          final String outfitName = availableOutfits.values.elementAt(index);
          final bool isSelected = habitProvider.currentOutfit == outfitAsset;

          return InkWell(
            onTap: () {
              habitProvider.changeOutfit(outfitAsset);
            },
            borderRadius: BorderRadius.circular(16.0),
            child: Card(
              elevation: isSelected ? 6.0 : 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  width: 3.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: outfitAsset == 'default'
                          ? Icon(Icons.no_stroller_rounded, size: 60, color: colorScheme.onSurface.withOpacity(0.5))
                          : Image.asset(
                              'assets/images/$outfitAsset',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error_outline, color: Colors.red, size: 40);
                              },
                            ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      outfitName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}