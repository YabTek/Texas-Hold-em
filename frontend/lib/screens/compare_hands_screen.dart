import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CompareHandsScreen extends StatefulWidget {
  const CompareHandsScreen({Key? key}) : super(key: key);

  @override
  State<CompareHandsScreen> createState() => _CompareHandsScreenState();
}

class _CompareHandsScreenState extends State<CompareHandsScreen> {
  final ApiService _apiService = ApiService();
  final List<TextEditingController> _p1HoleControllers =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> _p1BoardControllers =
      List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _p2HoleControllers =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> _p2BoardControllers =
      List.generate(5, (_) => TextEditingController());

  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    for (var controller in _p1HoleControllers) {
      controller.dispose();
    }
    for (var controller in _p1BoardControllers) {
      controller.dispose();
    }
    for (var controller in _p2HoleControllers) {
      controller.dispose();
    }
    for (var controller in _p2BoardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isValidCard(String card) {
    if (card.length != 2) return false;
    final suit = card[0].toUpperCase();
    final rank = card[1].toUpperCase();
    return ['H', 'S', 'C', 'D'].contains(suit) &&
           ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K'].contains(rank);
  }

  String? _validateInputs() {
    // Check Player 1 hole cards
    for (int i = 0; i < _p1HoleControllers.length; i++) {
      final card = _p1HoleControllers[i].text.trim().toUpperCase();
      if (card.isEmpty) {
        return 'Please enter Player 1 hole card ${i + 1}';
      }
      if (!_isValidCard(card)) {
        return 'Invalid Player 1 card: ${_p1HoleControllers[i].text}\nUse format like HA, S7, CT, DK';
      }
    }

    // Check Player 1 community cards
    for (int i = 0; i < _p1BoardControllers.length; i++) {
      final card = _p1BoardControllers[i].text.trim().toUpperCase();
      if (card.isEmpty) {
        return 'Please enter all 5 community cards for Player 1';
      }
      if (!_isValidCard(card)) {
        return 'Invalid Player 1 community card: ${_p1BoardControllers[i].text}\nUse format like HA, S7, CT, DK';
      }
    }

    // Check Player 2 hole cards
    for (int i = 0; i < _p2HoleControllers.length; i++) {
      final card = _p2HoleControllers[i].text.trim().toUpperCase();
      if (card.isEmpty) {
        return 'Please enter Player 2 hole card ${i + 1}';
      }
      if (!_isValidCard(card)) {
        return 'Invalid Player 2 card: ${_p2HoleControllers[i].text}\nUse format like HA, S7, CT, DK';
      }
    }

    // Check Player 2 community cards
    for (int i = 0; i < _p2BoardControllers.length; i++) {
      final card = _p2BoardControllers[i].text.trim().toUpperCase();
      if (card.isEmpty) {
        return 'Please enter all 5 community cards for Player 2';
      }
      if (!_isValidCard(card)) {
        return 'Invalid Player 2 community card: ${_p2BoardControllers[i].text}\nUse format like HA, S7, CT, DK';
      }
    }

    return null; // All valid
  }

  Future<void> _compareHands() async {
    // Validate inputs first
    final validationError = _validateInputs();
    if (validationError != null) {
      setState(() {
        _error = validationError;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final p1Hole = _p1HoleControllers.map((c) => c.text.toUpperCase()).toList();
      final p1Board = _p1BoardControllers.map((c) => c.text.toUpperCase()).toList();
      final p2Hole = _p2HoleControllers.map((c) => c.text.toUpperCase()).toList();
      final p2Board = _p2BoardControllers.map((c) => c.text.toUpperCase()).toList();

      final result = await _apiService.compareHands(p1Hole, p1Board, p2Hole, p2Board);

      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Hands'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPlayerSection(
              'Player 1',
              _p1HoleControllers,
              _p1BoardControllers,
            ),
            const SizedBox(height: 24),
            _buildPlayerSection(
              'Player 2',
              _p2HoleControllers,
              _p2BoardControllers,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _compareHands,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF2E8B57),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Compare Hands',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red[900],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              _buildWinnerCard(),
              const SizedBox(height: 16),
              _buildPlayerResult('Player 1', _result!['player1']),
              const SizedBox(height: 16),
              _buildPlayerResult('Player 2', _result!['player2']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSection(
    String title,
    List<TextEditingController> holeControllers,
    List<TextEditingController> boardControllers,
  ) {
    return Card(
      color: const Color(0xFF1e3a5f),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hole Cards (2)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (int i = 0; i < 2; i++) ...[
                  Expanded(
                    child: _buildCardInput(holeControllers[i], 'Card ${i + 1}'),
                  ),
                  if (i < 1) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Community Cards (5)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < 5; i++)
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 80) / 3,
                    child: _buildCardInput(boardControllers[i], 'Card ${i + 1}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        hintText: 'HA',
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF0d1b2a),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      textCapitalization: TextCapitalization.characters,
      maxLength: 2,
      buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) =>
          null,
    );
  }

  Widget _buildWinnerCard() {
    final winner = _result!['winner'];
    MaterialColor winnerColor;
    IconData icon;

    if (winner == 'Tie') {
      winnerColor = Colors.orange;
      icon = Icons.handshake;
    } else {
      winnerColor = Colors.blue;
      icon = Icons.emoji_events;
    }

    return Card(
      color: winnerColor[700],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Text(
              winner == 'Tie' ? 'It\'s a Tie!' : '$winner Wins!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerResult(String playerName, Map<String, dynamic> data) {
    return Card(
      color: const Color(0xFF1e3a5f),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              playerName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            _buildResultRow('Best Hand', data['bestHand']),
            _buildResultRow('Hand Value', data['handValue']),
            const SizedBox(height: 8),
            const Text(
              'Best 5 Cards:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                for (var card in data['cards']) _buildCardChip(card),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardChip(String card) {
    return Chip(
      label: Text(
        card,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: const Color(0xFF2E8B57),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
