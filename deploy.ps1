# Deploy Texas Hold'em Poker Application

Write-Host "`n=== Deploying Backend ===" -ForegroundColor Cyan
kubectl apply -f k8s/backend-deployment.yaml
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Backend deployed" -ForegroundColor Green
} else {
    Write-Host "✗ Backend deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Deploying Frontend ===" -ForegroundColor Cyan
kubectl apply -f k8s/frontend-deployment.yaml
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Frontend deployed" -ForegroundColor Green
} else {
    Write-Host "✗ Frontend deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Waiting for pods to be ready ===" -ForegroundColor Cyan
kubectl wait --for=condition=Ready pod -l app=poker-backend --timeout=120s
kubectl wait --for=condition=Ready pod -l app=poker-frontend --timeout=120s

Write-Host "`n=== Pod Status ===" -ForegroundColor Cyan
kubectl get pods -o wide

Write-Host "`n=== Service Status ===" -ForegroundColor Cyan
kubectl get services

Write-Host "`n=== Getting External IP ===" -ForegroundColor Cyan
Write-Host "Waiting for LoadBalancer IP assignment..." -ForegroundColor Yellow
Start-Sleep -Seconds 30
$externalIP = kubectl get service poker-frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
if ($externalIP) {
    Write-Host "External IP assigned: $externalIP" -ForegroundColor Green
    Write-Host "Frontend: http://$externalIP" -ForegroundColor Cyan
    Write-Host "Test the application at the URL above!" -ForegroundColor Yellow
} else {
    Write-Host "External IP not assigned yet. Run: kubectl get service poker-frontend-service" -ForegroundColor Yellow
}
