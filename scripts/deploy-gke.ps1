# Texas Hold'em Poker - GKE Deployment Script (PowerShell)
# This script deploys the poker application to Google Kubernetes Engine

param(
    [string]$ProjectId = "your-gcp-project-id",
    [string]$ClusterName = "poker-cluster",
    [string]$Region = "us-central1",
    [string]$Zone = "us-central1-a"
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Texas Hold'em Poker - GKE Deployment" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if required tools are installed
Write-Host "Checking required tools..." -ForegroundColor Yellow
try {
    gcloud version | Out-Null
    kubectl version --client | Out-Null
    docker --version | Out-Null
    Write-Host "✓ All required tools are installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Missing required tools. Please install gcloud, kubectl, and docker." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Set GCP project
Write-Host "Setting GCP project to: $ProjectId" -ForegroundColor Yellow
gcloud config set project $ProjectId

# Enable required APIs
Write-Host "Enabling required GCP APIs..." -ForegroundColor Yellow
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
Write-Host "✓ APIs enabled" -ForegroundColor Green
Write-Host ""

# Create GKE cluster (if it doesn't exist)
$clusterExists = gcloud container clusters describe $ClusterName --zone=$Zone 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Cluster $ClusterName already exists" -ForegroundColor Yellow
} else {
    Write-Host "Creating GKE cluster: $ClusterName" -ForegroundColor Yellow
    gcloud container clusters create $ClusterName `
        --zone=$Zone `
        --num-nodes=3 `
        --machine-type=e2-medium `
        --enable-autoscaling `
        --min-nodes=2 `
        --max-nodes=10 `
        --enable-autorepair `
        --enable-autoupgrade
    Write-Host "✓ Cluster created" -ForegroundColor Green
}
Write-Host ""

# Get cluster credentials
Write-Host "Getting cluster credentials..." -ForegroundColor Yellow
gcloud container clusters get-credentials $ClusterName --zone=$Zone
Write-Host "✓ Credentials configured" -ForegroundColor Green
Write-Host ""

# Build and push Docker images
Write-Host "Building and pushing Docker images..." -ForegroundColor Yellow

# Backend
Write-Host "Building backend image..." -ForegroundColor Yellow
Set-Location backend
docker build -t "gcr.io/$ProjectId/poker-backend:latest" .
docker push "gcr.io/$ProjectId/poker-backend:latest"
Set-Location ..
Write-Host "✓ Backend image pushed" -ForegroundColor Green

# Frontend
Write-Host "Building frontend image..." -ForegroundColor Yellow
Set-Location frontend
docker build -t "gcr.io/$ProjectId/poker-frontend:latest" .
docker push "gcr.io/$ProjectId/poker-frontend:latest"
Set-Location ..
Write-Host "✓ Frontend image pushed" -ForegroundColor Green
Write-Host ""

# Update Kubernetes manifests with project ID
Write-Host "Updating Kubernetes manifests..." -ForegroundColor Yellow
(Get-Content k8s\backend-deployment.yaml) -replace 'YOUR_PROJECT_ID', $ProjectId | Set-Content k8s\backend-deployment.yaml
(Get-Content k8s\frontend-deployment.yaml) -replace 'YOUR_PROJECT_ID', $ProjectId | Set-Content k8s\frontend-deployment.yaml
Write-Host "✓ Manifests updated" -ForegroundColor Green
Write-Host ""

# Deploy to Kubernetes
Write-Host "Deploying to Kubernetes..." -ForegroundColor Yellow
kubectl apply -f k8s\configmap.yaml
kubectl apply -f k8s\backend-deployment.yaml
kubectl apply -f k8s\frontend-deployment.yaml
kubectl apply -f k8s\hpa.yaml
Write-Host "✓ Deployments created" -ForegroundColor Green
Write-Host ""

# Wait for deployments to be ready
Write-Host "Waiting for deployments to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/poker-backend
kubectl wait --for=condition=available --timeout=300s deployment/poker-frontend
Write-Host "✓ Deployments are ready" -ForegroundColor Green
Write-Host ""

# Get service information
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Getting service information..." -ForegroundColor Yellow
kubectl get services
Write-Host ""
Write-Host "Getting pod information..." -ForegroundColor Yellow
kubectl get pods
Write-Host ""

# Get external IP
Write-Host "Waiting for external IP to be assigned..." -ForegroundColor Yellow
$externalIp = ""
for ($i = 1; $i -le 30; $i++) {
    $externalIp = kubectl get service poker-frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    if ($externalIp) {
        break
    }
    Write-Host "Waiting for external IP... ($i/30)" -ForegroundColor Yellow
    Start-Sleep -Seconds 10
}

if ($externalIp) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "Application is now accessible at:" -ForegroundColor Green
    Write-Host "Frontend: http://$externalIp" -ForegroundColor Green
    Write-Host "Backend API: http://$externalIp/api" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
} else {
    Write-Host "External IP not yet assigned. Run 'kubectl get services' to check status." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  kubectl get pods                    - View pods" -ForegroundColor White
Write-Host "  kubectl get services                - View services" -ForegroundColor White
Write-Host "  kubectl logs <pod-name>             - View logs" -ForegroundColor White
Write-Host "  kubectl describe pod <pod-name>     - Describe pod" -ForegroundColor White
Write-Host "  kubectl scale deployment poker-backend --replicas=5  - Scale deployment" -ForegroundColor White
