import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use relative URL - nginx will proxy /api/* to the backend service
  static const String baseUrl = '';

  Future<Map<String, dynamic>> evaluateHand(
      List<String> holeCards, List<String> boardCards) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/evaluate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'holeCards': holeCards,
          'boardCards': boardCards,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to evaluate hand: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> compareHands(
      List<String> player1Hole,
      List<String> player2Hole,
      List<String> communityCards) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/compare'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'player1HoleCards': player1Hole,
          'player2HoleCards': player2Hole,
          'communityCards': communityCards,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to compare hands: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> monteCarlo(
      List<String> holeCards,
      List<String> boardCards,
      int numPlayers,
      int numSimulations) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/montecarlo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'holeCards': holeCards,
          'boardCards': boardCards,
          'numPlayers': numPlayers,
          'numSimulations': numSimulations,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to run Monte Carlo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}
