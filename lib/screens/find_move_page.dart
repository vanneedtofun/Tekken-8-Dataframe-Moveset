import 'package:flutter/material.dart';

import '../models/move_model.dart';
import '../services/tekken_api_service.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/move_card.dart';

class FindMovePage extends StatefulWidget {
  final String characterName;
  final String query;
  final bool searchByNotation;

  const FindMovePage({
    super.key,
    required this.characterName,
    required this.query,
    required this.searchByNotation,
  });

  @override
  State<FindMovePage> createState() => _FindMovePageState();
}

class _FindMovePageState extends State<FindMovePage> {
  final TekkenApiService _apiService = TekkenApiService();

  late Future<List<MoveModel>> _movesFuture;

  @override
  void initState() {
    super.initState();
    _search();
  }

  void _search() {
    _movesFuture = _apiService.findMove(
      characterName: widget.characterName,
      moveName: widget.searchByNotation ? null : widget.query,
      notation: widget.searchByNotation ? widget.query : null,
    );
  }

  void _retry() {
    setState(_search);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Pencarian Jurus')),
      body: FutureBuilder<List<MoveModel>>(
        future: _movesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return ErrorWidgetView(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          final moves = snapshot.data ?? [];

          if (moves.isEmpty) {
            return const Center(child: Text('Jurus tidak ditemukan.'));
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Karakter: ${widget.characterName}\n'
                  'Pencarian: ${widget.query}\n'
                  'Ditemukan: ${moves.length} jurus',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...moves.map((move) => MoveCard(move: move)),
            ],
          );
        },
      ),
    );
  }
}
