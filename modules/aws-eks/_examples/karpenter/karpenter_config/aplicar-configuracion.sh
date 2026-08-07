#!/bin/bash

# Script para aplicar la configuración completa de Karpenter
# 1. Instala el chart de Karpenter
# 2. Aplica los NodePools (EC2NodeClass y NodePool para dev)
# 3. Aplica el deployment de ejemplo para dev

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 Aplicando configuración completa de Karpenter..."
echo ""

# Paso 1: Instalar Karpenter
echo "📦 Paso 1/3: Instalando chart de Karpenter..."
./instalar-karpenter.sh

echo ""
echo "⏳ Esperando 10 segundos para que Karpenter esté listo..."
sleep 10

# Paso 2: Aplicar EC2NodeClass y NodePool
echo ""
echo "📦 Paso 2/3: Aplicando EC2NodeClass y NodePools..."
echo "   Aplicando EC2NodeClass on-demand por defecto..."
kubectl apply -f ec2nodeclass-on-demand-default.yaml

echo "   Aplicando NodePool on-demand por defecto..."
kubectl apply -f nodepool-on-demand-default.yaml

echo "   Aplicando NodePool on-demand dev..."
kubectl apply -f nodepool-on-demand-dev.yaml

echo ""
echo "⏳ Esperando 5 segundos..."
sleep 5

# Paso 3: Aplicar deployment de ejemplo
echo ""
echo "📦 Paso 3/3: Aplicando deployment de ejemplo para dev..."
kubectl apply -f deployment-dev.yaml

echo ""
echo "✅ Configuración aplicada correctamente"
echo ""
echo "📊 Verificando estado..."
echo ""
echo "NodePools:"
kubectl get nodepool -n kube-system
echo ""
echo "EC2NodeClass:"
kubectl get ec2nodeclass
echo ""
echo "Deployments:"
kubectl get deployments -n default
echo ""
echo "Pods:"
kubectl get pods -n default -o wide
echo ""
echo "Nodos:"
kubectl get nodes --show-labels
echo ""
echo "💡 Para ver los logs de Karpenter:"
echo "   kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --tail=50"
