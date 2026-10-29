import 'package:flutter/material.dart';

import 'find_move_page.dart';
import 'move_table_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _characterController = TextEditingController(
    text: 'kazuya',
  );

  final TextEditingController _queryController = TextEditingController();

  String _searchType = 'Nama Jurus';

  @override
  void dispose() {
    _characterController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _openMoveTable() {
    final character = _characterController.text.trim();

    if (character.isEmpty) {
      _showMessage('Masukkan nama karakter terlebih dahulu.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoveTablePage(characterName: character),
      ),
    );
  }

  void _searchMove() {
    final character = _characterController.text.trim();
    final query = _queryController.text.trim();

    if (character.isEmpty || query.isEmpty) {
      _showMessage('Isi nama karakter dan kata pencarian.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FindMovePage(
          characterName: character,
          query: query,
          searchByNotation: _searchType == 'Notasi Tombol',
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TEKKEN MOVE GUIDE'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.sports_martial_arts, size: 76),
          const SizedBox(height: 12),
          Text(
            'Tekken 8 Move Guide',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Temukan jurus, damage, startup frame, '
            'dan informasi gerakan karakter favoritmu.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _characterController,
            decoration: const InputDecoration(
              labelText: 'Nama karakter',
              hintText: 'Contoh: kazuya, jin, claudio',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _openMoveTable,
              icon: const Icon(Icons.list_alt),
              label: const Text('Lihat Semua Jurus'),
            ),
          ),
          const SizedBox(height: 28),
          Text('Cari Jurus', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _searchType,
            decoration: const InputDecoration(
              labelText: 'Jenis pencarian',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Nama Jurus', child: Text('Nama Jurus')),
              DropdownMenuItem(
                value: 'Notasi Tombol',
                child: Text('Notasi Tombol'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _searchType = value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _queryController,
            decoration: InputDecoration(
              labelText: _searchType == 'Nama Jurus'
                  ? 'Nama jurus'
                  : 'Notasi tombol',
              hintText: _searchType == 'Nama Jurus'
                  ? 'Contoh: jab'
                  : 'Contoh: 1 atau df+2',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _searchMove(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _searchMove,
              icon: const Icon(Icons.search),
              label: const Text('Cari Jurus'),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sumber data: Tekken8-API komunitas.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
