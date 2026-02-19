package poker

import (
	"testing"
)

func TestPokerHandEvaluation(t *testing.T) {
	tests := []struct {
		name          string
		holeCards     []string
		communityCards []string
		expectedRank  string
	}{
		// High Card tests
		{
			name:          "High Card - SK CA D6 S9 H4",
			holeCards:     []string{"SK", "CA"},
			communityCards: []string{"D6", "S9", "H4", "D3", "C2"},
			expectedRank:  "High Card",
		},
		
		// One Pair tests
		{
			name:          "One Pair - DK C5 SK HT C8 C7 D2",
			holeCards:     []string{"DK", "C5"},
			communityCards: []string{"SK", "HT", "C8", "C7", "D2"},
			expectedRank:  "One Pair",
		},
		
		// Two Pairs tests
		{
			name:          "Two Pairs - HA C3 SA DQ CK D6 H6",
			holeCards:     []string{"HA", "C3"},
			communityCards: []string{"SA", "DQ", "CK", "D6", "H6"},
			expectedRank:  "Two Pair",
		},
		{
			name:          "Two Pairs - HQ C3 SA DQ CK D6 H6",
			holeCards:     []string{"HQ", "C3"},
			communityCards: []string{"SA", "DQ", "CK", "D6", "H6"},
			expectedRank:  "Two Pair",
		},
		
		// Three of a Kind tests
		{
			name:          "Three of a Kind - HJ SJ SA D3 H2 C8 SJ",
			holeCards:     []string{"HJ", "SJ"},
			communityCards: []string{"SA", "D3", "H2", "C8", "SJ"},
			expectedRank:  "Three of a Kind",
		},
		
		// Straight tests
		{
			name:          "Straight - D7 HA H3 S4 C5 S6 HT",
			holeCards:     []string{"D7", "HA"},
			communityCards: []string{"H3", "S4", "C5", "S6", "HT"},
			expectedRank:  "Straight",
		},
		{
			name:          "Straight - H2 SA H3 S4 C5 S6 HT",
			holeCards:     []string{"H2", "SA"},
			communityCards: []string{"H3", "S4", "C5", "S6", "HT"},
			expectedRank:  "Straight",
		},
		
		// Flush tests
		{
			name:          "Flush - DK DA D3 D6 DT C5 HQ",
			holeCards:     []string{"DK", "DA"},
			communityCards: []string{"D3", "D6", "DT", "C5", "HQ"},
			expectedRank:  "Flush",
		},
		{
			name:          "Flush - C3 HA D3 D6 DT DJ DK",
			holeCards:     []string{"C3", "HA"},
			communityCards: []string{"D3", "D6", "DT", "DJ", "DK"},
			expectedRank:  "Flush",
		},
		
		// Full House tests
		{
			name:          "Full House - S2 S5 HA SA DA HT S5",
			holeCards:     []string{"S2", "S5"},
			communityCards: []string{"HA", "SA", "DA", "HT", "S5"},
			expectedRank:  "Full House",
		},
		
		// Four of a Kind tests
		{
			name:          "Four of a Kind - CA SA DA HA HT S5 D2",
			holeCards:     []string{"CA", "SA"},
			communityCards: []string{"DA", "HA", "HT", "S5", "D2"},
			expectedRank:  "Four of a Kind",
		},
		
		// Straight Flush tests
		{
			name:          "Straight Flush - D6 D7 D3 D4 D5 HT C2",
			holeCards:     []string{"D6", "D7"},
			communityCards: []string{"D3", "D4", "D5", "HT", "C2"},
			expectedRank:  "Straight Flush",
		},
		
		// Royal Flush tests
		{
			name:          "Royal Flush - DA DK DT DJ DQ H2 C3",
			holeCards:     []string{"DA", "DK"},
			communityCards: []string{"DT", "DJ", "DQ", "H2", "C3"},
			expectedRank:  "Royal Flush",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			allCards := append(tt.holeCards, tt.communityCards...)
			handRank, _, _ := EvaluateHand(allCards)
			
			if handRank != tt.expectedRank {
				t.Errorf("Expected %s, got %s for cards: %v", 
					tt.expectedRank, handRank, allCards)
			}
		})
	}
}

func TestCompareHands(t *testing.T) {
	tests := []struct {
		name           string
		player1Hole    []string
		player1Community []string
		player2Hole    []string
		player2Community []string
		expectedWinner string
	}{
		{
			name:           "High Card - SK > SQ",
			player1Hole:    []string{"SK", "CA"},
			player1Community: []string{"D6", "S9", "H4", "S3", "C2"},
			player2Hole:    []string{"HA", "SQ"},
			player2Community: []string{"D6", "S9", "H4", "S3", "C2"},
			expectedWinner: "Player 1",
		},
		{
			name:           "One Pair - K > 8",
			player1Hole:    []string{"DK", "C5"},
			player1Community: []string{"SK", "HT", "C8", "C7", "D2"},
			player2Hole:    []string{"H8", "D5"},
			player2Community: []string{"SK", "HT", "C8", "C7", "D2"},
			expectedWinner: "Player 1",
		},
		{
			name:           "Two Pairs - A > Q",
			player1Hole:    []string{"HA", "C3"},
			player1Community: []string{"SA", "DQ", "CK", "D6", "H6"},
			player2Hole:    []string{"CQ", "H4"},
			player2Community: []string{"SA", "DQ", "CK", "D6", "H6"},
			expectedWinner: "Player 1",
		},
		{
			name:           "Flush - A > Q",
			player1Hole:    []string{"DK", "DA"},
			player1Community: []string{"D3", "D6", "DT", "C5", "HQ"},
			player2Hole:    []string{"D2", "DQ"},
			player2Community: []string{"D3", "D6", "DT", "C5", "HQ"},
			expectedWinner: "Player 1",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			p1Cards := append(tt.player1Hole, tt.player1Community...)
			p2Cards := append(tt.player2Hole, tt.player2Community...)
			
			winner := CompareHands(p1Cards, p2Cards)
			
			if winner != tt.expectedWinner {
				t.Errorf("Expected %s, got %s", tt.expectedWinner, winner)
			}
		})
	}
}

func TestCardParsing(t *testing.T) {
	tests := []struct {
		cardStr     string
		shouldError bool
	}{
		{"HA", false},
		{"SK", false},
		{"D7", false},
		{"CT", false},
		{"XX", true},
		{"H1", true},
		{"ZA", true},
		{"", true},
	}

	for _, tt := range tests {
		t.Run(tt.cardStr, func(t *testing.T) {
			_, err := ParseCard(tt.cardStr)
			if tt.shouldError && err == nil {
				t.Errorf("Expected error for card: %s", tt.cardStr)
			}
			if !tt.shouldError && err != nil {
				t.Errorf("Unexpected error for card %s: %v", tt.cardStr, err)
			}
		})
	}
}
