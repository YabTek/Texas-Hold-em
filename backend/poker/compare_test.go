package poker

import (
	"encoding/csv"
	"os"
	"strings"
	"testing"
)

func TestCompareHandsCSV(t *testing.T) {
	file, err := os.Open("../../Texas HoldEm Hand comparison test cases.xlsx - Sheet1.csv")
	if err != nil {
		t.Fatalf("Failed to open CSV file: %v", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		t.Fatalf("Failed to read CSV: %v", err)
	}

	// Skip header row
	for i := 1; i < len(records); i++ {
		record := records[i]
		
		// Skip empty rows
		if len(record) < 7 || strings.TrimSpace(record[1]) == "" {
			continue
		}

		communityCards := parseCardString(record[1]) // Column 2
		player1Hole := parseCardString(record[2])     // Column 3
		player2Hole := parseCardString(record[4])     // Column 5
		expectedResult := strings.TrimSpace(record[6]) // Column 7

		if len(communityCards) != 5 {
			continue // Skip invalid rows
		}
		if len(player1Hole) != 2 || len(player2Hole) != 2 {
			continue // Skip invalid rows
		}

		// Combine cards: 2 hole + 5 community = 7 cards for each player
		allCards1 := append(player1Hole, communityCards...)
		allCards2 := append(player2Hole, communityCards...)

		result := CompareHands(allCards1, allCards2)
		
		// Normalize expected result
		expectedNormalized := ""
		if strings.Contains(expectedResult, "hand 1 > hand 2") {
			expectedNormalized = "Player 1"
		} else if strings.Contains(expectedResult, "hand 2 > hand 1") {
			expectedNormalized = "Player 2"
		} else if strings.Contains(expectedResult, "hand 1 = hand 2") {
			expectedNormalized = "Tie"
		} else {
			continue // Skip rows with unexpected result format
		}

		if result != expectedNormalized {
			hand1, value1, _ := EvaluateHand(allCards1)
			hand2, value2, _ := EvaluateHand(allCards2)
			t.Errorf("Row %d:\nCommunity: %v\nPlayer 1 Hole: %v -> %s (%s)\nPlayer 2 Hole: %v -> %s (%s)\nExpected: %s, Got: %s",
				i+1, communityCards, player1Hole, hand1, value1, player2Hole, hand2, value2, expectedNormalized, result)
		}
	}
}
