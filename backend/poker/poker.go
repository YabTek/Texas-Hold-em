package poker

import (
	"fmt"
	"sort"
	"strings"
)

// Card represents a playing card
type Card struct {
	Suit  string
	Rank  string
	Value int
}

var rankValues = map[string]int{
	"2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
	"T": 10, "J": 11, "Q": 12, "K": 13, "A": 14,
}

var rankNames = map[string]string{
	"2": "2", "3": "3", "4": "4", "5": "5", "6": "6", "7": "7", "8": "8", "9": "9",
	"T": "10", "J": "Jack", "Q": "Queen", "K": "King", "A": "Ace",
}

// ParseCard converts a card string (e.g., "HA", "S7") to a Card struct
func ParseCard(cardStr string) (Card, error) {
	if len(cardStr) != 2 {
		return Card{}, fmt.Errorf("invalid card format: %s", cardStr)
	}

	suit := strings.ToUpper(string(cardStr[0]))
	rank := strings.ToUpper(string(cardStr[1]))

	if suit != "H" && suit != "D" && suit != "C" && suit != "S" {
		return Card{}, fmt.Errorf("invalid suit: %s", suit)
	}

	value, ok := rankValues[rank]
	if !ok {
		return Card{}, fmt.Errorf("invalid rank: %s", rank)
	}

	return Card{Suit: suit, Rank: rank, Value: value}, nil
}

// ParseCards converts a slice of card strings to Card structs
func ParseCards(cardStrs []string) ([]Card, error) {
	cards := make([]Card, len(cardStrs))
	for i, cardStr := range cardStrs {
		card, err := ParseCard(cardStr)
		if err != nil {
			return nil, err
		}
		cards[i] = card
	}
	return cards, nil
}

// HandRank represents the rank of a poker hand
type HandRank int

const (
	HighCard HandRank = iota
	OnePair
	TwoPair
	ThreeOfAKind
	Straight
	Flush
	FullHouse
	FourOfAKind
	StraightFlush
	RoyalFlush
)

func (hr HandRank) String() string {
	names := []string{
		"High Card", "One Pair", "Two Pair", "Three of a Kind",
		"Straight", "Flush", "Full House", "Four of a Kind",
		"Straight Flush", "Royal Flush",
	}
	return names[hr]
}

// HandScore represents the score of a poker hand for comparison
type HandScore struct {
	Rank     HandRank
	Values   []int
	BestCards []Card
}

// EvaluateBestHand finds the best 5-card hand from 7 cards
func EvaluateBestHand(cards []Card) HandScore {
	if len(cards) < 5 {
		return HandScore{Rank: HighCard, Values: []int{}}
	}

	// Generate all 5-card combinations from 7 cards
	combinations := generateCombinations(cards, 5)

	if len(combinations) == 0 {
		return HandScore{Rank: HighCard, Values: []int{}}
	}

	// Initialize with first combination
	bestScore := evaluateFiveCards(combinations[0])

	// Compare with remaining combinations
	for i := 1; i < len(combinations); i++ {
		score := evaluateFiveCards(combinations[i])
		if compareScores(score, bestScore) > 0 {
			bestScore = score
		}
	}

	return bestScore
}

func generateCombinations(cards []Card, k int) [][]Card {
	var result [][]Card
	n := len(cards)

	var helper func(start int, combo []Card)
	helper = func(start int, combo []Card) {
		if len(combo) == k {
			newCombo := make([]Card, k)
			copy(newCombo, combo)
			result = append(result, newCombo)
			return
		}

		for i := start; i < n; i++ {
			helper(i+1, append(combo, cards[i]))
		}
	}

	helper(0, []Card{})
	return result
}

func evaluateFiveCards(cards []Card) HandScore {
	if len(cards) != 5 {
		return HandScore{Rank: HighCard, Values: []int{}}
	}

	// Sort cards by value (descending)
	sortedCards := make([]Card, 5)
	copy(sortedCards, cards)
	sort.Slice(sortedCards, func(i, j int) bool {
		return sortedCards[i].Value > sortedCards[j].Value
	})

	isFlush := checkFlush(sortedCards)
	straightValue := checkStraight(sortedCards)
	isStraight := straightValue > 0

	if isFlush && isStraight {
		if straightValue == 14 { // Ace-high straight
			return HandScore{Rank: RoyalFlush, Values: []int{14}, BestCards: sortedCards}
		}
		return HandScore{Rank: StraightFlush, Values: []int{straightValue}, BestCards: sortedCards}
	}

	rankCounts := make(map[int]int)
	for _, card := range sortedCards {
		rankCounts[card.Value]++
	}

	var counts []int
	var values []int
	for value, count := range rankCounts {
		counts = append(counts, count)
		values = append(values, value)
	}

	sort.Slice(values, func(i, j int) bool {
		if rankCounts[values[i]] == rankCounts[values[j]] {
			return values[i] > values[j]
		}
		return rankCounts[values[i]] > rankCounts[values[j]]
	})

	// Four of a kind
	if rankCounts[values[0]] == 4 {
		return HandScore{Rank: FourOfAKind, Values: values, BestCards: sortedCards}
	}

	// Full house
	if rankCounts[values[0]] == 3 && rankCounts[values[1]] == 2 {
		return HandScore{Rank: FullHouse, Values: values, BestCards: sortedCards}
	}

	// Flush
	if isFlush {
		vals := make([]int, 5)
		for i, card := range sortedCards {
			vals[i] = card.Value
		}
		return HandScore{Rank: Flush, Values: vals, BestCards: sortedCards}
	}

	// Straight
	if isStraight {
		return HandScore{Rank: Straight, Values: []int{straightValue}, BestCards: sortedCards}
	}

	// Three of a kind
	if rankCounts[values[0]] == 3 {
		return HandScore{Rank: ThreeOfAKind, Values: values, BestCards: sortedCards}
	}

	// Two pair
	if rankCounts[values[0]] == 2 && rankCounts[values[1]] == 2 {
		return HandScore{Rank: TwoPair, Values: values, BestCards: sortedCards}
	}

	// One pair
	if rankCounts[values[0]] == 2 {
		return HandScore{Rank: OnePair, Values: values, BestCards: sortedCards}
	}

	// High card
	vals := make([]int, 5)
	for i, card := range sortedCards {
		vals[i] = card.Value
	}
	return HandScore{Rank: HighCard, Values: vals, BestCards: sortedCards}
}

func checkFlush(cards []Card) bool {
	suit := cards[0].Suit
	for _, card := range cards {
		if card.Suit != suit {
			return false
		}
	}
	return true
}

func checkStraight(cards []Card) int {
	// Check for regular straight
	for i := 0; i < 4; i++ {
		if cards[i].Value-cards[i+1].Value != 1 {
			// Check for A-2-3-4-5 (wheel)
			if i == 0 && cards[0].Value == 14 && cards[1].Value == 5 &&
				cards[2].Value == 4 && cards[3].Value == 3 && cards[4].Value == 2 {
				return 5 // Return 5 as the high card for the wheel
			}
			return 0
		}
	}
	return cards[0].Value
}

func compareScores(s1, s2 HandScore) int {
	if s1.Rank != s2.Rank {
		if s1.Rank > s2.Rank {
			return 1
		}
		return -1
	}

	// Same rank, compare values
	minLen := len(s1.Values)
	if len(s2.Values) < minLen {
		minLen = len(s2.Values)
	}

	for i := 0; i < minLen; i++ {
		if s1.Values[i] > s2.Values[i] {
			return 1
		}
		if s1.Values[i] < s2.Values[i] {
			return -1
		}
	}

	return 0
}

// EvaluateHand evaluates a poker hand and returns the best hand name, value description, and cards
func EvaluateHand(cardStrs []string) (string, string, []string) {
	cards, err := ParseCards(cardStrs)
	if err != nil {
		return "Error", err.Error(), []string{}
	}

	score := EvaluateBestHand(cards)
	
	valueDesc := formatHandValue(score)
	bestCardStrs := make([]string, len(score.BestCards))
	for i, card := range score.BestCards {
		bestCardStrs[i] = card.Suit + card.Rank
	}

	return score.Rank.String(), valueDesc, bestCardStrs
}

func formatHandValue(score HandScore) string {
	// Handle empty values array
	if len(score.Values) == 0 {
		return "Invalid hand"
	}
	
	switch score.Rank {
	case RoyalFlush:
		return "Royal Flush"
	case StraightFlush:
		return fmt.Sprintf("Straight Flush, %s high", rankNames[getRankStr(score.Values[0])])
	case FourOfAKind:
		return fmt.Sprintf("Four %ss", rankNames[getRankStr(score.Values[0])])
	case FullHouse:
		if len(score.Values) < 2 {
			return "Invalid Full House"
		}
		return fmt.Sprintf("Full House, %ss full of %ss", rankNames[getRankStr(score.Values[0])], rankNames[getRankStr(score.Values[1])])
	case Flush:
		return fmt.Sprintf("Flush, %s high", rankNames[getRankStr(score.Values[0])])
	case Straight:
		return fmt.Sprintf("Straight, %s high", rankNames[getRankStr(score.Values[0])])
	case ThreeOfAKind:
		return fmt.Sprintf("Three %ss", rankNames[getRankStr(score.Values[0])])
	case TwoPair:
		if len(score.Values) < 2 {
			return "Invalid Two Pair"
		}
		return fmt.Sprintf("Two Pair, %ss and %ss", rankNames[getRankStr(score.Values[0])], rankNames[getRankStr(score.Values[1])])
	case OnePair:
		return fmt.Sprintf("Pair of %ss", rankNames[getRankStr(score.Values[0])])
	case HighCard:
		return fmt.Sprintf("%s high", rankNames[getRankStr(score.Values[0])])
	}
	return "Unknown"
}

func getRankStr(value int) string {
	for rank, val := range rankValues {
		if val == value {
			return rank
		}
	}
	return ""
}

// CompareHands compares two hands and returns "Player 1", "Player 2", or "Tie"
func CompareHands(cards1Strs, cards2Strs []string) string {
	cards1, err := ParseCards(cards1Strs)
	if err != nil {
		return "Error"
	}

	cards2, err := ParseCards(cards2Strs)
	if err != nil {
		return "Error"
	}

	score1 := EvaluateBestHand(cards1)
	score2 := EvaluateBestHand(cards2)

	result := compareScores(score1, score2)
	if result > 0 {
		return "Player 1"
	} else if result < 0 {
		return "Player 2"
	}
	return "Tie"
}
