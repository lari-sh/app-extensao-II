import 'dart:typed_data';
import 'package:flutter/material.dart';

class AnimalPortrait extends StatelessWidget {
  const AnimalPortrait({
    super.key,
    this.bytes,
    required this.label,
    this.size = 120,
  });
  final List<int>? bytes;
  final String label;
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Semantics(
      label: label,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: bytes == null
            ? const Icon(Icons.pets, size: 48)
            : Image.memory(
                Uint8List.fromList(bytes!),
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, error, stack) =>
                    const Icon(Icons.pets, size: 48),
              ),
      ),
    ),
  );
}
