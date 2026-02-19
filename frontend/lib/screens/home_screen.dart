import 'package:flutter/material.dart';
import 'evaluate_hand_screen.dart';
import 'compare_hands_screen.dart';
import 'monte_carlo_screen.dart';
import 'rules_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TEXAS HOLD\'EM POKER',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1b263b),
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
                    children: [
                      Icon(
                        Icons.casino,
                        size: 80,
                        color: const Color(0xFFff6b35),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your action',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildMenuButton(
                  context,
                  'Evaluate Hand',
                  'Analyze your 2 hole cards + 5 community cards',
                  Icons.credit_card,
                  const Color(0xFF4a5bc0),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EvaluateHandScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'Compare Hands',
                  'Compare two poker hands head-to-head',
                  Icons.compare_arrows,
                  const Color(0xFF4a5bc0),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompareHandsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'Monte Carlo Simulation',
                  'Calculate win probability with simulations',
                  Icons.analytics,
                  const Color(0xFF4a5bc0),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MonteCarloScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'Poker Rules',
                  'Learn Texas Hold\'em rules and hand rankings',
                  Icons.info_outline,
                  const Color(0xFF4a5bc0),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RulesScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF415a77).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF778da9).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: const Color(0xFFff6b35),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Card Format',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Use 2 characters: Suit + Rank',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _buildCardExample('HA', 'Heart-Ace'),
                          _buildCardExample('S7', 'Spade-7'),
                          _buildCardExample('CT', 'Club-Ten'),
                          _buildCardExample('DK', 'Diamond-King'),
                          _buildCardExample('D2', 'Diamond-2'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardExample(String code, String description) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1b263b),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF4a5bc0).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            code,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFff6b35),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
