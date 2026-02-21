import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CompareHandsScreen extends StatefulWidget {
  const CompareHandsScreen({Key? key}) : super(key: key);

  @override
  State<CompareHandsScreen> createState() => _CompareHandsScreenState();
}

class _CompareHandsScreenState extends State<CompareHandsScreen> {
  final ApiService _apiService = ApiService();
  final List<TextEditingController> _communityControllers =
      List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _p1HoleControllers =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> _p2HoleControllers =
      List.generate(2, (_) => TextEditingController());

  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    for (var controller in _communityControllers) {
      controller.dispose();
    }
    for (var controller in _p1HoleControllers) {
      controller.dispose();
    }
    for (var controller in _p2HoleControllers) {
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
    // Check community cards
    for (int i = 0; i < _communityControllers.length; i++) {
      final card = _communityControllers[i].text.trim().toUpperCase();
      if (card.isEmpty) {
        return 'Please enter all 5 community cards';
      }
      if (!_isValidCard(card)) {
        return 'Invalid community card: ${_communityControllers[i].text}\nUse format like HA, S7, CT, DK';
      }
    }

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
      final communityCards = _communityControllers.map((c) => c.text.toUpperCase()).toList();
      final p1Hole = _p1HoleControllers.map((c) => c.text.toUpperCase()).toList();
      final p2Hole = _p2HoleControllers.map((c) => c.text.toUpperCase()).toList();

      final result = await _apiService.compareHands(p1Hole, p2Hole, communityCards);

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
        title: const Text('Compare Hands', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0d1b2a),
              const Color(0xFF1b263b),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Community Cards Section
              const Text(
                'COMMUNITY CARDS (SHARED)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFff6b35),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < 5; i++)
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 48) / 3,
                      child: _buildCardInput(_communityControllers[i], 'Card ${i + 1}'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Player 1 Section
              _buildPlayerSection(
                'PLAYER 1',
                _p1HoleControllers,
                const Color(0xFF1e3a5f),
              ),
              const SizedBox(height: 16),
              
              // Player 2 Section
              _buildPlayerSection(
                'PLAYER 2',
                _p2HoleControllers,
                const Color(0xFF1e3a5f),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _loading ? null : _compareHands,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                  backgroundColor: const Color(0xFF4a5bc0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'COMPARE HANDS',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFc1121f),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
      ),
    );
  }

  Widget _buildPlayerSection(
    String title,
    List<TextEditingController> holeControllers,
    Color cardColor,
  ) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hole Cards (2)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9db4c8),
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
        labelStyle: const TextStyle(color: Color(0xFF9db4c8), fontSize: 12),
        hintText: 'HA',
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF0d1b2a),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF4a90e2).withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF4a90e2).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4a90e2), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.characters,
      maxLength: 2,
      buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) =>
          null,
    );
  }

  Widget _buildWinnerCard() {
    final winner = _result!['winner'];
    Color winnerColor;
    IconData icon;

    if (winner == 'Tie') {
      winnerColor = const Color(0xFFff6b35);
      icon = Icons.handshake;
    } else {
      winnerColor = const Color(0xFF4a5bc0);
      icon = Icons.emoji_events;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: winnerColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerResult(String playerName, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1e3a5f),
            const Color(0xFF2a5a8f),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            playerName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFff6b35),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildResultRow('Best Hand', data['bestHand']),
          _buildResultRow('Hand Value', data['handValue']),
          const SizedBox(height: 12),
          const Text(
            'Best 5 Cards:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              for (var card in data['cards']) _buildCardChip(card),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF9db4c8),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
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
          fontSize: 14,
        ),
      ),
      backgroundColor: const Color(0xFF4a5bc0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
