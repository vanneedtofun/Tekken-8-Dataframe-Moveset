import 'package:flutter/material.dart';

import '../models/move_model.dart';
import '../services/tekken_api_service.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/move_card.dart';

class MoveTablePage extends StatefulWidget {
  final String characterName;

  const MoveTablePage({super.key, required this.characterName});

  @override
  State<MoveTablePage> createState() => _MoveTablePageState();
}

class _MoveTablePageState extends State<MoveTablePage> {
  final TekkenApiService _apiService = TekkenApiService();

  late Future<List<MoveModel>> _movesFuture;

  @override
  void initState() {
    super.initState();
    _loadMoves();
  }

  void _loadMoves() {
    _movesFuture = _apiService.getMoveTable(widget.characterName);
  }

  void _retry() {
    setState(_loadMoves);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.characterName} - Move List')),
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
            return const Center(
              child: Text('Tidak ada data jurus untuk karakter ini.'),
            );
          }

          return ListView.builder(
            itemCount: moves.length,
            itemBuilder: (context, index) {
              return MoveCard(move: moves[index]);
            },
          );
        },
      ),
    );
  }
}
