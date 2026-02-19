# Quick Deploy Script for Texas Hold'em Poker
Write-Host "=== Texas Hold'em Poker - Quick Deploy ===" -ForegroundColor Cyan
Write-Host ""

# Ensure we're in the k8s directory
cd "$PSScriptRoot\k8s"

# Apply all Kubernetes resources
Write-Host "Deploying resources..." -ForegroundColor Yellow
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f configmap.yaml
kubectl apply -f hpa.yaml

Write-Host ""
Write-Host "=== Waiting for deployments to be ready ===" -ForegroundColor Cyan
kubectl wait --for=condition=available --timeout=300s deployment/poker-backend
kubectl wait --for=condition=available --timeout=300s deployment/poker-frontend

Write-Host ""
Write-Host "=== Deployment Status ===" -ForegroundColor Cyan
kubectl get deployments
Write-Host ""
kubectl get pods
Write-Host ""
kubectl get services

Write-Host ""
Write-Host "=== Getting External IP ===" -ForegroundColor Cyan
Write-Host "Waiting for external IP to be assigned..." -ForegroundColor Yellow

$maxAttempts = 30
$attempt = 0
$externalIP = ""

while ($attempt -lt $maxAttempts) {
    $externalIP = kubectl get service poker-frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
    if ($externalIP) {
        break
    }
    $attempt++
    Write-Host "Attempt $attempt/$maxAttempts - Waiting for IP..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
}

Write-Host ""
if ($externalIP) {
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "🎉 Deployment Successful!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your application is accessible at:" -ForegroundColor Cyan
    Write-Host "Frontend:    http://$externalIP" -ForegroundColor White
    Write-Host "Backend API: http://$externalIP:8080" -ForegroundColor White
    Write-Host ""
    Write-Host "Test the health endpoint:" -ForegroundColor Yellow
    Write-Host "curl http://${externalIP}:8080/health" -ForegroundColor White
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
} else {
    Write-Host "External IP not yet assigned." -ForegroundColor Yellow
    Write-Host "Run this command to check:" -ForegroundColor Yellow
    Write-Host "kubectl get service poker-frontend-service" -ForegroundColor White
}
