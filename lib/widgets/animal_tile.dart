import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../theme.dart';

class AnimalPortrait extends StatelessWidget {
  const AnimalPortrait({super.key, required this.animal, this.height = 140});
  final Animal animal;
  final double height;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: double.infinity,
    color: softBackground,
    child: Center(
      child: Icon(
        animal.species == 'Gato' ? Icons.cruelty_free : Icons.pets,
        size: height * .45,
        color: brandBrown.withValues(alpha: .65),
      ),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final AnimalStatus status;
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AnimalStatus.available => const Color(0xFF276441),
      AnimalStatus.treatment => const Color(0xFF7B3F2B),
      AnimalStatus.quarantine => brandRed,
      AnimalStatus.adopted => const Color(0xFF395A85),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

void showStorageError(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível salvar. Tente novamente.'),
      ),
    );
