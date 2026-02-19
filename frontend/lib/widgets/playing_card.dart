import 'package:flutter/material.dart';

class PlayingCard extends StatelessWidget {
  final String? cardCode; // e.g., "HA", "SK", "D7"
  final double width;
  final double height;

  const PlayingCard({
    Key? key,
    this.cardCode,
    this.width = 80,
    this.height = 110,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cardCode == null || cardCode!.isEmpty || cardCode!.length != 2) {
      return _buildEmptyCard();
    }

    final suit = cardCode![0].toUpperCase();
    final rank = cardCode![1].toUpperCase();
    
    return _buildCard(suit, rank);
  }

  Widget _buildEmptyCard() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1e3a5f),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4a90e2).withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.add,
          color: Colors.white.withOpacity(0.3),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildCard(String suit, String rank) {
    final Color suitColor = _getSuitColor(suit);
    final String suitSymbol = _getSuitSymbol(suit);
    final String rankDisplay = _getRankDisplay(rank);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top-left rank and suit
          Positioned(
            top: 4,
            left: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  rankDisplay,
                  style: TextStyle(
                    color: suitColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                Text(
                  suitSymbol,
                  style: TextStyle(
                    color: suitColor,
                    fontSize: 16,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Center suit symbol
          Center(
            child: Text(
              suitSymbol,
              style: TextStyle(
                color: suitColor.withOpacity(0.3),
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Bottom-right rank and suit (rotated)
          Positioned(
            bottom: 4,
            right: 6,
            child: Transform.rotate(
              angle: 3.14159, // 180 degrees
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    rankDisplay,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    suitSymbol,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 16,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSuitColor(String suit) {
    switch (suit) {
      case 'H': // Hearts
      case 'D': // Diamonds
        return const Color(0xFFD32F2F); // Red
      case 'S': // Spades
      case 'C': // Clubs
        return const Color(0xFF212121); // Black
      default:
        return Colors.grey;
    }
  }

  String _getSuitSymbol(String suit) {
    switch (suit) {
      case 'H':
        return '♥';
      case 'D':
        return '♦';
      case 'S':
        return '♠';
      case 'C':
        return '♣';
      default:
        return '?';
    }
  }

  String _getRankDisplay(String rank) {
    switch (rank) {
      case 'A':
        return 'A';
      case 'K':
        return 'K';
      case 'Q':
        return 'Q';
      case 'J':
        return 'J';
      case 'T':
        return '10';
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        return rank;
      default:
        return '?';
    }
  }
}
