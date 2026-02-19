package poker

import (
	"math/rand"
	"time"
)

// MonteCarloSimulation runs Monte Carlo simulation to calculate win probability
func MonteCarloSimulation(holeCardsStrs, boardCardsStrs []string, numPlayers, numSimulations int) (float64, float64, float64) {
	holeCards, err := ParseCards(holeCardsStrs)
	if err != nil {
		return 0, 0, 0
	}

	boardCards, err := ParseCards(boardCardsStrs)
	if err != nil {
		return 0, 0, 0
	}

	usedCards := make(map[string]bool)
	for _, cardStr := range holeCardsStrs {
		usedCards[cardStr] = true
	}
	for _, cardStr := range boardCardsStrs {
		usedCards[cardStr] = true
	}

	wins := 0
	ties := 0
	losses := 0

	rng := rand.New(rand.NewSource(time.Now().UnixNano()))

	for i := 0; i < numSimulations; i++ {
		result := simulateHand(holeCards, boardCards, usedCards, numPlayers, rng)
		if result > 0 {
			wins++
		} else if result == 0 {
			ties++
		} else {
			losses++
		}
	}

	winProb := float64(wins) / float64(numSimulations)
	tieProb := float64(ties) / float64(numSimulations)
	lossProb := float64(losses) / float64(numSimulations)

	return winProb, tieProb, lossProb
}

func simulateHand(holeCards, boardCards []Card, usedCards map[string]bool, numPlayers int, rng *rand.Rand) int {
	// Create a copy of used cards for this simulation
	simUsedCards := make(map[string]bool)
	for k, v := range usedCards {
		simUsedCards[k] = v
	}

	// Complete the board if needed
	simBoard := make([]Card, len(boardCards))
	copy(simBoard, boardCards)

	cardsNeeded := 5 - len(simBoard)
	for i := 0; i < cardsNeeded; i++ {
		card := drawRandomCard(simUsedCards, rng)
		simBoard = append(simBoard, card)
		simUsedCards[card.Suit+card.Rank] = true
	}

	// Evaluate our hand
	ourCards := append(holeCards, simBoard...)
	ourScore := EvaluateBestHand(ourCards)

	// Simulate opponent hands
	bestOpponentScore := HandScore{Rank: HighCard, Values: []int{}}
	
	for p := 1; p < numPlayers; p++ {
		// Deal opponent hole cards
		oppHole1 := drawRandomCard(simUsedCards, rng)
		simUsedCards[oppHole1.Suit+oppHole1.Rank] = true
		
		oppHole2 := drawRandomCard(simUsedCards, rng)
		simUsedCards[oppHole2.Suit+oppHole2.Rank] = true

		oppCards := []Card{oppHole1, oppHole2}
		oppCards = append(oppCards, simBoard...)
		oppScore := EvaluateBestHand(oppCards)

		if compareScores(oppScore, bestOpponentScore) > 0 {
			bestOpponentScore = oppScore
		}

		// Return cards to pool for next opponent
		delete(simUsedCards, oppHole1.Suit+oppHole1.Rank)
		delete(simUsedCards, oppHole2.Suit+oppHole2.Rank)
	}

	return compareScores(ourScore, bestOpponentScore)
}

func drawRandomCard(usedCards map[string]bool, rng *rand.Rand) Card {
	suits := []string{"H", "D", "C", "S"}
	ranks := []string{"2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"}

	for {
		suit := suits[rng.Intn(len(suits))]
		rank := ranks[rng.Intn(len(ranks))]
		cardStr := suit + rank

		if !usedCards[cardStr] {
			return Card{
				Suit:  suit,
				Rank:  rank,
				Value: rankValues[rank],
			}
		}
	}
}
