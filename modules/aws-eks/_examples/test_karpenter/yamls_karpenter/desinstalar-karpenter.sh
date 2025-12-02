#!/bin/bash

# Script para desinstalar Karpenter y limpiar todos los recursos
# Elimina en orden: deployments -> NodePools/EC2NodeClass -> Karpenter chart

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🗑️  Desinstalando Karpenter y limpiando recursos..."
echo ""

# Paso 1: Eliminar deployments de ejemplo
echo "📦 Paso 1/3: Eliminando deployments de ejemplo..."
kubectl delete -f deployment-dev.yaml --ignore-not-found=true || true
echo "   ✅ Deployments eliminados"

echo ""
echo "⏳ Esperando a que los pods terminen..."
sleep 20

# Paso 2: Eliminar NodePools y EC2NodeClass usando los archivos YAML
echo ""
echo "📦 Paso 2/3: Eliminando NodePools y EC2NodeClass..."
kubectl delete -n kube-system -f karpenter-dev-v1.yaml --ignore-not-found=true || true
echo "   ✅ NodePool karpenter-dev eliminado"

kubectl delete -n kube-system -f karpenter-on-demand-default-v1.yaml --ignore-not-found=true || true
echo "   ✅ NodePool y EC2NodeClass karpenter-on-demand-default eliminados"

echo ""
echo "⏳ Esperando a que los nodos se eliminen..."
sleep 20

# Paso 3: Desinstalar Karpenter con Helm
echo ""
echo "📦 Paso 3/3: Desinstalando Karpenter (Helm)..."
helm uninstall karpenter -n karpenter --ignore-not-found=true || true
echo "   ✅ Karpenter desinstalado"

echo ""
echo "✅ Desinstalación completada"
echo ""
echo "📊 Verificación final:"
echo ""
echo "NodePools restantes:"
kubectl get nodepool -n kube-system 2>/dev/null || echo "   Ninguno"
echo ""
echo "EC2NodeClass restantes:"
kubectl get ec2nodeclass 2>/dev/null || echo "   Ninguno"
echo ""
echo "Pods de Karpenter:"
kubectl get pods -n karpenter 2>/dev/null || echo "   Namespace karpenter no existe o está vacío"

