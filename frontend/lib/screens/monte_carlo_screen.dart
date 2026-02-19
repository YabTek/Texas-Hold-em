import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/playing_card.dart';

class MonteCarloScreen extends StatefulWidget {
  const MonteCarloScreen({Key? key}) : super(key: key);

  @override
  State<MonteCarloScreen> createState() => _MonteCarloScreenState();
}

class _MonteCarloScreenState extends State<MonteCarloScreen> {
  final ApiService _apiService = ApiService();
  final List<TextEditingController> _holeControllers =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> _communityControllers =
      List.generate(5, (_) => TextEditingController());
  final TextEditingController _playersController = TextEditingController(text: '6');
  final TextEditingController _simulationsController =
      TextEditingController(text: '10000');

  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    for (var controller in _holeControllers) {
      controller.dispose();
    }
    for (var controller in _communityControllers) {
      controller.dispose();
    }
    _playersController.dispose();
    _simulationsController.dispose();
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
    // Check hole cards
    for (int i = 0; i < _holeControllers.length; i++) {
      final card = _holeControllers[i].text.trim().toUpperCase();
      if (card.isEmpty) {
        return 'Please enter hole card ${i + 1}';
      }
      if (!_isValidCard(card)) {
        return 'Invalid card format: ${_holeControllers[i].text}\nUse format like HA, S7, CT, DK';
      }
    }

    // Check community cards (optional)
    for (int i = 0; i < _communityControllers.length; i++) {
      final card = _communityControllers[i].text.trim().toUpperCase();
      if (card.isNotEmpty && !_isValidCard(card)) {
        return 'Invalid card format: ${_communityControllers[i].text}\nUse format like HA, S7, CT, DK';
      }
    }

    // Check number of players
    try {
      final players = int.parse(_playersController.text);
      if (players < 2 || players > 10) {
        return 'Number of players must be between 2 and 10';
      }
    } catch (e) {
      return 'Please enter a valid number of players';
    }

    // Check number of simulations
    try {
      final sims = int.parse(_simulationsController.text);
      if (sims < 100 || sims > 100000) {
        return 'Number of simulations must be between 100 and 100,000';
      }
    } catch (e) {
      return 'Please enter a valid number of simulations';
    }

    return null; // All valid
  }

  Future<void> _runMonteCarlo() async {
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
      final holeCards =
          _holeControllers.map((c) => c.text.toUpperCase()).toList();
      final boardCards = _communityControllers
          .where((c) => c.text.isNotEmpty)
          .map((c) => c.text.toUpperCase())
          .toList();
      final numPlayers = int.parse(_playersController.text);
      final numSimulations = int.parse(_simulationsController.text);

      final result = await _apiService.monteCarlo(
        holeCards,
        boardCards,
        numPlayers,
        numSimulations,
      );

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
        title: const Text('Monte Carlo Simulation', style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Text(
                'YOUR HOLE CARDS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFff6b35),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 2; i++) ...[ 
                    PlayingCard(
                      cardCode: _holeControllers[i].text.isNotEmpty ? _holeControllers[i].text : null,
                      width: 100,
                      height: 140,
                    ),
                    if (i < 1) const SizedBox(width: 16),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int i = 0; i < 2; i++) ...[
                    Expanded(
                      child: _buildCardInput(_holeControllers[i], 'Card ${i + 1}'),
                    ),
                    if (i < 1) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'COMMUNITY CARDS (OPTIONAL)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFff6b35),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 5; i++) ...[
                    PlayingCard(
                      cardCode: _communityControllers[i].text.isNotEmpty ? _communityControllers[i].text : null,
                      width: 60,
                      height: 84,
                    ),
                    if (i < 4) const SizedBox(width: 8),
                  ],
                ],
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
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e3a5f).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'GAME SETTINGS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFff6b35),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            _playersController,
                            'Players',
                            '2-10',
                            Icons.people,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberInput(
                            _simulationsController,
                            'Simulations',
                            '100-100k',
                            Icons.loop,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _runMonteCarlo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                  backgroundColor: const Color(0xFFff6b35),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CALCULATE WIN PROBABILITY',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
                Container(
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
                      const Text(
                        '📊 WIN PROBABILITY',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFff6b35),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProbabilityBar(
                        'Win',
                        _result!['winProbability'],
                        const Color(0xFF06d6a0),
                      ),
                      const SizedBox(height: 12),
                      _buildProbabilityBar(
                        'Tie',
                        _result!['tieProbability'],
                        const Color(0xFFffd166),
                      ),
                      const SizedBox(height: 12),
                      _buildProbabilityBar(
                        'Loss',
                        _result!['lossProbability'],
                        const Color(0xFFef476f),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          '${_result!['simulations']} simulations',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9db4c8), fontSize: 12),
        hintText: 'HA',
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF1e3a5f),
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

  Widget _buildNumberInput(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9db4c8), fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF4a90e2), size: 20),
        hintText: hint,
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
      ),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildProbabilityBar(String label, double probability, Color color) {
    final percentage = (probability * 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: probability,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 24,
          ),
        ),
      ],
    );
  }
}
