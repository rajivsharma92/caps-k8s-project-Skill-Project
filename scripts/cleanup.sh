#!/bin/bash

set -e  # Exit on error

echo "Starting cleanup for SaleProject..."

# 1. Kill any background port-forward processes related to kubectl
echo "Stopping port-forward processes..."
pkill -f "kubectl port-forward" || echo "No port-forward processes found."

# 2. Delete the entire namespace (which deletes all resources inside it)
echo "Deleting namespace 'saleproject'..."
kubectl delete namespace saleproject || echo "Namespace not found. Skipping..."

# 3. Optional: Unset the current namespace from your kubectl context
echo "Resetting kubectl context..."
kubectl config set-context --current --namespace=default

echo "Cleanup complete."
