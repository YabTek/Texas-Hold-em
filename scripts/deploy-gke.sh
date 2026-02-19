#!/bin/bash

# Texas Hold'em Poker - GKE Deployment Script
# This script deploys the poker application to Google Kubernetes Engine

set -e

# Configuration
PROJECT_ID=${PROJECT_ID:-"your-gcp-project-id"}
CLUSTER_NAME=${CLUSTER_NAME:-"poker-cluster"}
REGION=${REGION:-"us-central1"}
ZONE=${ZONE:-"us-central1-a"}

echo "============================================"
echo "Texas Hold'em Poker - GKE Deployment"
echo "============================================"
echo ""

# Check if required tools are installed
echo "Checking required tools..."
command -v gcloud >/dev/null 2>&1 || { echo "gcloud is not installed. Please install Google Cloud SDK."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is not installed. Please install kubectl."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Docker is not installed. Please install Docker."; exit 1; }

echo "✓ All required tools are installed"
echo ""

# Set GCP project
echo "Setting GCP project to: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "Enabling required GCP APIs..."
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
echo "✓ APIs enabled"
echo ""

# Create GKE cluster (if it doesn't exist)
if gcloud container clusters describe $CLUSTER_NAME --zone=$ZONE >/dev/null 2>&1; then
    echo "Cluster $CLUSTER_NAME already exists"
else
    echo "Creating GKE cluster: $CLUSTER_NAME"
    gcloud container clusters create $CLUSTER_NAME \
        --zone=$ZONE \
        --num-nodes=3 \
        --machine-type=e2-medium \
        --enable-autoscaling \
        --min-nodes=2 \
        --max-nodes=10 \
        --enable-autorepair \
        --enable-autoupgrade
    echo "✓ Cluster created"
fi
echo ""

# Get cluster credentials
echo "Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone=$ZONE
echo "✓ Credentials configured"
echo ""

# Build and push Docker images
echo "Building and pushing Docker images..."

# Backend
echo "Building backend image..."
cd backend
docker build -t gcr.io/$PROJECT_ID/poker-backend:latest .
docker push gcr.io/$PROJECT_ID/poker-backend:latest
cd ..
echo "✓ Backend image pushed"

# Frontend
echo "Building frontend image..."
cd frontend
docker build -t gcr.io/$PROJECT_ID/poker-frontend:latest .
docker push gcr.io/$PROJECT_ID/poker-frontend:latest
cd ..
echo "✓ Frontend image pushed"
echo ""

# Update Kubernetes manifests with project ID
echo "Updating Kubernetes manifests..."
sed -i "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s/backend-deployment.yaml
sed -i "s/YOUR_PROJECT_ID/$PROJECT_ID/g" k8s/frontend-deployment.yaml
echo "✓ Manifests updated"
echo ""

# Deploy to Kubernetes
echo "Deploying to Kubernetes..."
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/hpa.yaml
echo "✓ Deployments created"
echo ""

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/poker-backend
kubectl wait --for=condition=available --timeout=300s deployment/poker-frontend
echo "✓ Deployments are ready"
echo ""

# Get service information
echo "============================================"
echo "Deployment Complete!"
echo "============================================"
echo ""
echo "Getting service information..."
kubectl get services
echo ""
echo "Getting pod information..."
kubectl get pods
echo ""

# Get external IP
echo "Waiting for external IP to be assigned..."
for i in {1..30}; do
    EXTERNAL_IP=$(kubectl get service poker-frontend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ ! -z "$EXTERNAL_IP" ]; then
        break
    fi
    echo "Waiting for external IP... ($i/30)"
    sleep 10
done

if [ ! -z "$EXTERNAL_IP" ]; then
    echo ""
    echo "============================================"
    echo "Application is now accessible at:"
    echo "Frontend: http://$EXTERNAL_IP"
    echo "Backend API: http://$EXTERNAL_IP/api"
    echo "============================================"
else
    echo "External IP not yet assigned. Run 'kubectl get services' to check status."
fi

echo ""
echo "Useful commands:"
echo "  kubectl get pods                    - View pods"
echo "  kubectl get services                - View services"
echo "  kubectl logs <pod-name>             - View logs"
echo "  kubectl describe pod <pod-name>     - Describe pod"
echo "  kubectl scale deployment poker-backend --replicas=5  - Scale deployment"
