# Texas Hold'em Poker - Quick Start Guide

## Quick Start - Local Development (5 minutes)

### Option 1: Docker Compose (Recommended)

1. **Clone and navigate to the project:**
   ```bash
   cd Texas-Hold-em
   ```

2. **Start the application:**
   ```bash
   docker-compose up --build
   ```

3. **Access the application:**
   - Frontend: http://localhost
   - Backend API: http://localhost:8080

That's it! The application is now running locally.

### Option 2: Run Backend and Frontend Separately

#### Backend:
```bash
cd backend
go mod download
go run main.go
```

#### Frontend:
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

**Note:** Update the `baseUrl` in `frontend/lib/services/api_service.dart` if needed.

## Quick Start - Deploy to GKE (15 minutes)

### Prerequisites Check:
```bash
gcloud --version
kubectl version --client
docker --version
```

If any are missing, see the full README for installation instructions.

### Deploy:

**Windows PowerShell:**
```powershell
cd scripts
.\deploy-gke.ps1 -ProjectId "your-gcp-project-id"
```

**Linux/Mac:**
```bash
cd scripts
chmod +x deploy-gke.sh
export PROJECT_ID="your-gcp-project-id"
./deploy-gke.sh
```

The script will:
1. Create a GKE cluster
2. Build and push Docker images
3. Deploy the application
4. Provide you with the external IP address

## Testing the API

### Using curl:

```bash
# Health check
curl http://localhost:8080/health

# Evaluate hand
curl -X POST http://localhost:8080/api/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "holeCards": ["HA", "HK"],
    "boardCards": ["HQ", "HJ", "HT", "D2", "C3"]
  }'

# Compare hands
curl -X POST http://localhost:8080/api/compare \
  -H "Content-Type: application/json" \
  -d '{
    "player1": {
      "holeCards": ["HA", "HK"],
      "boardCards": ["HQ", "HJ", "HT", "D2", "C3"]
    },
    "player2": {
      "holeCards": ["SA", "SK"],
      "boardCards": ["HQ", "HJ", "HT", "D2", "C3"]
    }
  }'

# Monte Carlo simulation
curl -X POST http://localhost:8080/api/montecarlo \
  -H "Content-Type: application/json" \
  -d '{
    "holeCards": ["HA", "HK"],
    "boardCards": ["HQ", "HJ"],
    "numPlayers": 6,
    "numSimulations": 10000
  }'
```

### Using PowerShell:

```powershell
# Health check
Invoke-RestMethod -Uri "http://localhost:8080/health" -Method Get

# Evaluate hand
$body = @{
    holeCards = @("HA", "HK")
    boardCards = @("HQ", "HJ", "HT", "D2", "C3")
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/evaluate" -Method Post -Body $body -ContentType "application/json"
```

## Load Testing

```bash
cd k6
k6 run load-test.js
```

## Useful Commands

### Docker:
```bash
# Stop containers
docker-compose down

# Rebuild and start
docker-compose up --build

# View logs
docker-compose logs -f
```

### Kubernetes:
```bash
# View pods
kubectl get pods

# View services
kubectl get services

# View logs
kubectl logs -l app=poker-backend

# Scale deployment
kubectl scale deployment poker-backend --replicas=5
```

## Card Examples

- `HA` = Heart Ace
- `S7` = Spade 7
- `CT` = Club Ten (T = Ten)
- `DQ` = Diamond Queen
- `HK` = Heart King

## Next Steps

1. Try the different features in the frontend
2. Run load tests with k6
3. Scale the deployments and observe HPA in action
4. Check the logs and monitoring
5. Customize the application for your needs

## Troubleshooting

**Backend won't start:**
- Check if port 8080 is available
- Verify Go is installed: `go version`
- Run `go mod download` in the backend directory

**Frontend won't start:**
- Check if port 80 is available
- Verify Flutter is installed: `flutter doctor`
- Run `flutter pub get` in the frontend directory

**Docker issues:**
- Make sure Docker is running
- Try `docker-compose down` and then `docker-compose up --build`

**GKE deployment issues:**
- Verify GCP credentials: `gcloud auth list`
- Check project ID: `gcloud config get-value project`
- Ensure APIs are enabled: `gcloud services list --enabled`

For more details, see the full [README.md](README.md).
