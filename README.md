# Texas Hold'em Poker Application

A containerized Texas Hold'em Poker application with Go backend and Flutter frontend, designed for deployment on Kubernetes (GKE).

## Features

- **Hand Evaluation**: Analyze 2 hole cards + 5 board cards to determine the best poker hand
- **Hand Comparison**: Compare two poker hands head-to-head to determine the winner
- **Monte Carlo Simulation**: Calculate win probability using Monte Carlo simulations
- **Poker Rules**: Built-in reference for Texas Hold'em rules and hand rankings

## Technology Stack

### Backend
- **Language**: Go 1.21
- **Framework**: Gorilla Mux (REST API)
- **Features**:
  - Poker hand evaluation algorithm (inspired by Peter Norvig)
  - Monte Carlo probability simulation
  - RESTful API with CORS support

### Frontend
- **Framework**: Flutter (Web)
- **UI**: Material Design with custom poker theme
- **Features**:
  - Responsive web interface
  - Interactive card input
  - Real-time API integration

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **Cloud Platform**: Google Cloud (GKE)
- **Load Testing**: k6

## Project Structure

```
Texas-Hold-em/
├── backend/
│   ├── main.go                 # REST API server
│   ├── poker/
│   │   ├── poker.go            # Hand evaluation logic
│   │   └── monte_carlo.go      # Monte Carlo simulation
│   ├── go.mod                  # Go dependencies
│   └── Dockerfile              # Backend container image
├── frontend/
│   ├── lib/
│   │   ├── main.dart           # App entry point
│   │   ├── services/
│   │   │   └── api_service.dart # API client
│   │   └── screens/
│   │       ├── home_screen.dart
│   │       ├── evaluate_hand_screen.dart
│   │       ├── compare_hands_screen.dart
│   │       ├── monte_carlo_screen.dart
│   │       └── rules_screen.dart
│   ├── pubspec.yaml            # Flutter dependencies
│   ├── Dockerfile              # Frontend container image
│   └── nginx.conf              # Nginx configuration
├── k8s/
│   ├── backend-deployment.yaml # Backend K8s deployment
│   ├── frontend-deployment.yaml# Frontend K8s deployment
│   ├── ingress.yaml            # Ingress configuration
│   ├── hpa.yaml                # Horizontal Pod Autoscaler
│   └── configmap.yaml          # Configuration
├── k6/
│   └── load-test.js            # Load testing script
├── scripts/
│   ├── deploy-gke.sh           # Bash deployment script
│   └── deploy-gke.ps1          # PowerShell deployment script
├── docker-compose.yml          # Local development setup
└── README.md                   # This file
```

## Card Notation

Cards are represented by 2 characters:
- **First character**: Suit (H=Hearts, D=Diamonds, C=Clubs, S=Spades)
- **Second character**: Rank (2-9, T=Ten, J=Jack, Q=Queen, K=King, A=Ace)

Examples:
- `HA` = Heart Ace
- `S7` = Spade 7
- `CT` = Club Ten
- `DQ` = Diamond Queen

## API Endpoints

### 1. Evaluate Hand
**POST** `/api/evaluate`
```json
{
  "holeCards": ["HA", "HK"],
  "boardCards": ["HQ", "HJ", "HT", "D2", "C3"]
}
```
Response:
```json
{
  "bestHand": "Royal Flush",
  "handValue": "Royal Flush",
  "cards": ["HA", "HK", "HQ", "HJ", "HT"]
}
```

### 2. Compare Hands
**POST** `/api/compare`
```json
{
  "player1": {
    "holeCards": ["HA", "HK"],
    "boardCards": ["HQ", "HJ", "HT", "D2", "C3"]
  },
  "player2": {
    "holeCards": ["SA", "SK"],
    "boardCards": ["HQ", "HJ", "HT", "D2", "C3"]
  }
}
```

### 3. Monte Carlo Simulation
**POST** `/api/montecarlo`
```json
{
  "holeCards": ["HA", "HK"],
  "boardCards": ["HQ", "HJ"],
  "numPlayers": 6,
  "numSimulations": 10000
}
```

### 4. Health Check
**GET** `/health`

## Local Development

### Prerequisites
- Docker
- Docker Compose
- Go 1.21+ (for local backend development)
- Flutter SDK (for local frontend development)

### Run with Docker Compose

1. Clone the repository:
```bash
git clone <repository-url>
cd Texas-Hold-em
```

2. Start the application:
```bash
docker-compose up --build
```

3. Access the application:
   - Frontend: http://localhost
   - Backend API: http://localhost:8080

### Run Backend Locally

```bash
cd backend
go mod download
go run main.go
```

### Run Frontend Locally

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

## Deployment to Google Kubernetes Engine (GKE)

### Prerequisites
- Google Cloud account
- gcloud CLI installed and configured
- kubectl installed
- Docker installed
- GKE-gcloud-auth-plugin installed

### Install Required Tools

#### Google Cloud SDK
**Windows:**
Download from: https://cloud.google.com/sdk/docs/install

**Linux/Mac:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

#### kubectl
```bash
gcloud components install kubectl
```

#### GKE Auth Plugin
```bash
gcloud components install gke-gcloud-auth-plugin
```

#### k6 (for load testing)
**Windows:**
```powershell
choco install k6
```

**Linux/Mac:**
```bash
# Linux
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

# Mac
brew install k6
```

### Deploy to GKE

#### Using PowerShell (Windows):
```powershell
cd scripts
.\deploy-gke.ps1 -ProjectId "your-gcp-project-id" -ClusterName "poker-cluster" -Zone "us-central1-a"
```

#### Using Bash (Linux/Mac):
```bash
cd scripts
chmod +x deploy-gke.sh
./deploy-gke.sh
```

Or set environment variables:
```bash
export PROJECT_ID="your-gcp-project-id"
export CLUSTER_NAME="poker-cluster"
export ZONE="us-central1-a"
./deploy-gke.sh
```

### Manual Deployment Steps

1. **Set up GCP project:**
```bash
gcloud config set project YOUR_PROJECT_ID
gcloud services enable container.googleapis.com
```

2. **Create GKE cluster:**
```bash
gcloud container clusters create poker-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=e2-medium \
  --enable-autoscaling \
  --min-nodes=2 \
  --max-nodes=10
```

3. **Get cluster credentials:**
```bash
gcloud container clusters get-credentials poker-cluster --zone=us-central1-a
```

4. **Build and push Docker images:**
```bash
# Backend
cd backend
docker build -t gcr.io/YOUR_PROJECT_ID/poker-backend:latest .
docker push gcr.io/YOUR_PROJECT_ID/poker-backend:latest

# Frontend
cd ../frontend
docker build -t gcr.io/YOUR_PROJECT_ID/poker-frontend:latest .
docker push gcr.io/YOUR_PROJECT_ID/poker-frontend:latest
```

5. **Update Kubernetes manifests:**
Edit `k8s/backend-deployment.yaml` and `k8s/frontend-deployment.yaml` to replace `YOUR_PROJECT_ID` with your actual GCP project ID.

6. **Deploy to Kubernetes:**
```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/hpa.yaml
```

7. **Check deployment status:**
```bash
kubectl get pods
kubectl get services
```

8. **Get external IP:**
```bash
kubectl get service poker-frontend-service
```

## Load Testing with k6

Run load tests against your deployment:

```bash
cd k6
k6 run load-test.js
```

Or against a specific endpoint:
```bash
k6 run --env BASE_URL=http://YOUR_EXTERNAL_IP load-test.js
```

## Kubernetes Management

### Useful Commands

```bash
# View pods
kubectl get pods

# View services
kubectl get services

# View logs
kubectl logs <pod-name>

# Describe pod
kubectl describe pod <pod-name>

# Scale deployment
kubectl scale deployment poker-backend --replicas=5

# Update deployment
kubectl set image deployment/poker-backend backend=gcr.io/YOUR_PROJECT_ID/poker-backend:new-tag

# Delete deployment
kubectl delete -f k8s/
```

### Horizontal Pod Autoscaling

The application is configured with Horizontal Pod Autoscaler (HPA):
- **Backend**: 2-10 replicas based on CPU (70%) and memory (80%) utilization
- **Frontend**: 2-5 replicas based on CPU (70%) utilization

View HPA status:
```bash
kubectl get hpa
```

## Monitoring and Debugging

### View logs:
```bash
# Backend logs
kubectl logs -l app=poker-backend

# Frontend logs
kubectl logs -l app=poker-frontend

# Follow logs
kubectl logs -f <pod-name>
```

### Check pod health:
```bash
kubectl get pods
kubectl describe pod <pod-name>
```

### Access pod shell:
```bash
kubectl exec -it <pod-name> -- /bin/sh
```

## Clean Up

### Delete Kubernetes resources:
```bash
kubectl delete -f k8s/
```

### Delete GKE cluster:
```bash
gcloud container clusters delete poker-cluster --zone=us-central1-a
```

## Poker Hand Rankings

1. **Royal Flush**: A, K, Q, J, 10, all of the same suit
2. **Straight Flush**: Five consecutive cards of the same suit
3. **Four of a Kind**: Four cards of the same rank
4. **Full House**: Three of a kind plus a pair
5. **Flush**: Five cards of the same suit, not in sequence
6. **Straight**: Five consecutive cards of different suits
7. **Three of a Kind**: Three cards of the same rank
8. **Two Pair**: Two different pairs
9. **One Pair**: Two cards of the same rank
10. **High Card**: No matching cards, highest card wins

## References

- [Texas Hold'em Rules - Wikipedia (English)](https://en.wikipedia.org/wiki/Texas_hold_%27em)
- [Texas Hold'em Rules - Wikipedia (German)](https://de.wikipedia.org/wiki/Texas_Hold%E2%80%99em)
- [Peter Norvig's Poker Hand Evaluator](http://norvig.com/poker.html)
- [Monte Carlo Method](https://en.wikipedia.org/wiki/Monte_Carlo_method)

## License

This project is provided as-is for educational purposes.

## Contributing

Feel free to submit issues, fork the repository, and create pull requests.

## Support

For issues or questions, please create an issue in the repository.
