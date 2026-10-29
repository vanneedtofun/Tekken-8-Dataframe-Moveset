import 'package:flutter/material.dart';

import '../models/move_model.dart';

class MoveCard extends StatelessWidget {
  final MoveModel move;

  const MoveCard({super.key, required this.move});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              move.nameMove.isEmpty ? 'Jurus tanpa nama' : move.nameMove,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Input: ${move.moveset}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip('Startup', move.startup),
                _infoChip('Damage', move.damage),
                _infoChip('Hit', move.onHit),
                _infoChip('Block', move.onBlock),
              ],
            ),
            if (move.hitProperties.isNotEmpty && move.hitProperties != '-') ...[
              const SizedBox(height: 10),
              Text('Hit properties: ${move.hitProperties}'),
            ],
            if (move.onCH.isNotEmpty && move.onCH != '-') ...[
              const SizedBox(height: 4),
              Text('Counter hit: ${move.onCH}'),
            ],
            if (move.states.isNotEmpty && move.states != '-') ...[
              const SizedBox(height: 4),
              Text('States: ${move.states}'),
            ],
            if (move.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(move.notes, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}
