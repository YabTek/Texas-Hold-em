import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poker Rules'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Texas Hold\'em Overview',
              'Texas Hold\'em is the most popular variant of poker. Each player is dealt two private cards '
              '(hole cards), and five community cards (board cards) are dealt face-up on the table. '
              'Players must make the best possible five-card poker hand using any combination of their '
              'two hole cards and the five community cards.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Hand Rankings (Highest to Lowest)',
              '',
            ),
            _buildHandRanking(
              '1. Royal Flush',
              'A, K, Q, J, 10, all of the same suit',
              'Example: HA HK HQ HJ HT',
            ),
            _buildHandRanking(
              '2. Straight Flush',
              'Five consecutive cards of the same suit',
              'Example: S9 S8 S7 S6 S5',
            ),
            _buildHandRanking(
              '3. Four of a Kind',
              'Four cards of the same rank',
              'Example: DA DK DS DC H7',
            ),
            _buildHandRanking(
              '4. Full House',
              'Three of a kind plus a pair',
              'Example: HK CK DK H9 C9',
            ),
            _buildHandRanking(
              '5. Flush',
              'Five cards of the same suit, not in sequence',
              'Example: HA H9 H7 H4 H2',
            ),
            _buildHandRanking(
              '6. Straight',
              'Five consecutive cards of different suits',
              'Example: HK CQ DJ CT S9',
            ),
            _buildHandRanking(
              '7. Three of a Kind',
              'Three cards of the same rank',
              'Example: H8 C8 D8 HK C4',
            ),
            _buildHandRanking(
              '8. Two Pair',
              'Two different pairs',
              'Example: HJ DJ H5 C5 CA',
            ),
            _buildHandRanking(
              '9. One Pair',
              'Two cards of the same rank',
              'Example: HA DA HK CQ D9',
            ),
            _buildHandRanking(
              '10. High Card',
              'No matching cards, highest card wins',
              'Example: HA CK D9 H7 S3',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Card Notation',
              'Cards are represented by two characters:\n'
              '• First character: Suit (H=Hearts, D=Diamonds, C=Clubs, S=Spades)\n'
              '• Second character: Rank (2-9, T=Ten, J=Jack, Q=Queen, K=King, A=Ace)\n\n'
              'Examples:\n'
              '• HA = Heart Ace\n'
              '• S7 = Spade 7\n'
              '• CT = Club Ten\n'
              '• DQ = Diamond Queen',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Game Phases',
              '1. Pre-flop: Each player receives 2 hole cards\n'
              '2. Flop: 3 community cards are revealed\n'
              '3. Turn: 4th community card is revealed\n'
              '4. River: 5th and final community card is revealed\n'
              '5. Showdown: Players reveal their hands and the best hand wins',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Poker Hand Evaluation (Peter Norvig)',
              'The poker hand evaluator uses algorithmic analysis to:\n'
              '• Parse card notation into structured data\n'
              '• Check for flushes (all same suit)\n'
              '• Check for straights (consecutive ranks)\n'
              '• Count rank frequencies for pairs, trips, quads\n'
              '• Find the best 5-card combination from 7 cards\n'
              '• Compare hands using rank hierarchy and kickers',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Monte Carlo Simulation',
              'The Monte Carlo simulation calculates win probability by:\n'
              '• Dealing random cards for opponents\n'
              '• Completing the board with random cards\n'
              '• Evaluating all hands at showdown\n'
              '• Repeating thousands of times\n'
              '• Calculating win/tie/loss percentages\n\n'
              'More simulations = more accurate probability',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'References',
              '• Texas Hold\'em rules: Wikipedia (EN/DE)\n'
              '• Hand evaluation algorithm: Peter Norvig\'s poker evaluator\n'
              '• Probability calculation: Monte Carlo method',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
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
            if (content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHandRanking(String title, String description, String example) {
    return Card(
      color: const Color(0xFF0d1b2a),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              example,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4a90e2),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
