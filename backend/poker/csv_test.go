package poker

import (
	"encoding/csv"
	"os"
	"strings"
	"testing"
)

func TestCSVTestCases(t *testing.T) {
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
	for i, record := range records[1:] {
		// Skip empty rows
		if len(record) < 7 || record[0] == "" {
			continue
		}

		handType := record[0]
		communityCards := parseCardString(record[1])
		player1Hole := parseCardString(record[2])
		player2Hole := parseCardString(record[4])
		expectedResult := record[6]
		comment := ""
		if len(record) > 8 {
			comment = record[8]
		}

		// Skip if no hole cards (community card only cases)
		if len(player1Hole) == 0 || len(player2Hole) == 0 {
			continue
		}

		testName := strings.TrimSpace(handType)
		if comment != "" {
			testName += " - " + comment
		}
		if testName == "" {
			testName = "Row " + string(rune(i+2))
		}

		t.Run(testName, func(t *testing.T) {
			// Combine hole cards + community cards
			p1Cards := append(player1Hole, communityCards...)
			p2Cards := append(player2Hole, communityCards...)

			winner := CompareHands(p1Cards, p2Cards)

			var expected string
			if strings.Contains(expectedResult, "hand 1 > hand 2") {
				expected = "Player 1"
			} else if strings.Contains(expectedResult, "hand 2 > hand 1") {
				expected = "Player 2"
			} else if strings.Contains(expectedResult, "hand 1 = hand 2") {
				expected = "Tie"
			} else {
				t.Skipf("Unknown result format: %s", expectedResult)
				return
			}

			if winner != expected {
				// Evaluate both hands to see details
				rank1, desc1, _ := EvaluateHand(p1Cards)
				rank2, desc2, _ := EvaluateHand(p2Cards)
				
				t.Errorf("Expected %s, got %s\n"+
					"Player 1: %v → %s (%s)\n"+
					"Player 2: %v → %s (%s)\n"+
					"Community: %v",
					expected, winner,
					player1Hole, rank1, desc1,
					player2Hole, rank2, desc2,
					communityCards)
			}
		})
	}
}

func parseCardString(s string) []string {
	s = strings.TrimSpace(s)
	if s == "" || s == "–" {
		return []string{}
	}
	
	// Split by spaces and filter empty strings
	parts := strings.Fields(s)
	var cards []string
	for _, part := range parts {
		part = strings.TrimSpace(part)
		if part != "" && part != "–" {
			cards = append(cards, part)
		}
	}
	return cards
}

func TestHandEvaluationFromCSV(t *testing.T) {
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

	// Test hand evaluation for each row
	for i, record := range records[1:] {
		if len(record) < 7 || record[0] == "" {
			continue
		}

		handType := strings.TrimSpace(record[0])
		communityCards := parseCardString(record[1])
		player1Hole := parseCardString(record[2])

		if len(player1Hole) == 0 || len(communityCards) == 0 {
			continue
		}

		testName := handType + " - Row " + string(rune(i+2))

		t.Run(testName, func(t *testing.T) {
			allCards := append(player1Hole, communityCards...)
			rank, desc, bestCards := EvaluateHand(allCards)

			// Just verify it doesn't crash and returns valid data
			if rank == "" {
				t.Errorf("Empty rank returned for cards: %v", allCards)
			}
			if desc == "" {
				t.Errorf("Empty description returned for cards: %v", allCards)
			}
			if len(bestCards) != 5 {
				t.Errorf("Expected 5 best cards, got %d: %v", len(bestCards), bestCards)
			}

			// Log the result for verification
			t.Logf("Cards: %v + %v → %s: %s (Best: %v)", 
				player1Hole, communityCards, rank, desc, bestCards)
		})
	}
}
