package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"texas-holdem-backend/poker"

	"github.com/gorilla/mux"
)

type EvaluateHandRequest struct {
	HoleCards []string `json:"holeCards"`
	BoardCards []string `json:"boardCards"`
}

type EvaluateHandResponse struct {
	BestHand string `json:"bestHand"`
	HandValue string `json:"handValue"`
	Cards []string `json:"cards"`
}

type CompareHandsRequest struct {
	Player1HoleCards []string `json:"player1HoleCards"`
	Player2HoleCards []string `json:"player2HoleCards"`
	CommunityCards []string `json:"communityCards"`
}

type CompareHandsResponse struct {
	Player1 EvaluateHandResponse `json:"player1"`
	Player2 EvaluateHandResponse `json:"player2"`
	Winner string `json:"winner"`
}

type MonteCarloRequest struct {
	HoleCards []string `json:"holeCards"`
	BoardCards []string `json:"boardCards"`
	NumPlayers int `json:"numPlayers"`
	NumSimulations int `json:"numSimulations"`
}

type MonteCarloResponse struct {
	WinProbability float64 `json:"winProbability"`
	TieProbability float64 `json:"tieProbability"`
	LossProbability float64 `json:"lossProbability"`
	Simulations int `json:"simulations"`
}

func enableCORS(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
}

func handleEvaluateHand(w http.ResponseWriter, r *http.Request) {
	enableCORS(w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	var req EvaluateHandRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, fmt.Sprintf("Invalid request: %v", err), http.StatusBadRequest)
		return
	}

	if len(req.HoleCards) != 2 || len(req.BoardCards) != 5 {
		http.Error(w, "Must provide exactly 2 hole cards and 5 board cards", http.StatusBadRequest)
		return
	}

	allCards := append(req.HoleCards, req.BoardCards...)
	hand, value, bestCards := poker.EvaluateHand(allCards)

	response := EvaluateHandResponse{
		BestHand: hand,
		HandValue: value,
		Cards: bestCards,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func handleCompareHands(w http.ResponseWriter, r *http.Request) {
	enableCORS(w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	var req CompareHandsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, fmt.Sprintf("Invalid request: %v", err), http.StatusBadRequest)
		return
	}

	if len(req.Player1HoleCards) != 2 {
		http.Error(w, "Player 1: Must provide exactly 2 hole cards", http.StatusBadRequest)
		return
	}

	if len(req.Player2HoleCards) != 2 {
		http.Error(w, "Player 2: Must provide exactly 2 hole cards", http.StatusBadRequest)
		return
	}

	if len(req.CommunityCards) != 5 {
		http.Error(w, "Must provide exactly 5 community cards", http.StatusBadRequest)
		return
	}

	// Each player's 7 cards = 2 hole cards + 5 community cards
	allCards1 := append(req.Player1HoleCards, req.CommunityCards...)
	hand1, value1, bestCards1 := poker.EvaluateHand(allCards1)

	allCards2 := append(req.Player2HoleCards, req.CommunityCards...)
	hand2, value2, bestCards2 := poker.EvaluateHand(allCards2)

	winner := poker.CompareHands(allCards1, allCards2)

	response := CompareHandsResponse{
		Player1: EvaluateHandResponse{
			BestHand: hand1,
			HandValue: value1,
			Cards: bestCards1,
		},
		Player2: EvaluateHandResponse{
			BestHand: hand2,
			HandValue: value2,
			Cards: bestCards2,
		},
		Winner: winner,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func handleMonteCarlo(w http.ResponseWriter, r *http.Request) {
	enableCORS(w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	var req MonteCarloRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, fmt.Sprintf("Invalid request: %v", err), http.StatusBadRequest)
		return
	}

	if len(req.HoleCards) != 2 {
		http.Error(w, "Must provide exactly 2 hole cards", http.StatusBadRequest)
		return
	}

	if len(req.BoardCards) > 5 {
		http.Error(w, "Board cards cannot exceed 5 cards", http.StatusBadRequest)
		return
	}

	if req.NumPlayers < 2 || req.NumPlayers > 10 {
		http.Error(w, "Number of players must be between 2 and 10", http.StatusBadRequest)
		return
	}

	if req.NumSimulations < 100 || req.NumSimulations > 100000 {
		http.Error(w, "Number of simulations must be between 100 and 100000", http.StatusBadRequest)
		return
	}

	winProb, tieProb, lossProb := poker.MonteCarloSimulation(req.HoleCards, req.BoardCards, req.NumPlayers, req.NumSimulations)

	response := MonteCarloResponse{
		WinProbability: winProb,
		TieProbability: tieProb,
		LossProbability: lossProb,
		Simulations: req.NumSimulations,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	enableCORS(w)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
}

func main() {
	r := mux.NewRouter()

	r.HandleFunc("/health", handleHealth).Methods("GET", "OPTIONS")
	r.HandleFunc("/api/evaluate", handleEvaluateHand).Methods("POST", "OPTIONS")
	r.HandleFunc("/api/compare", handleCompareHands).Methods("POST", "OPTIONS")
	r.HandleFunc("/api/montecarlo", handleMonteCarlo).Methods("POST", "OPTIONS")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting server on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, r))
}
