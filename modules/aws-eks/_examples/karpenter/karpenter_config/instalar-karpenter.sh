#!/bin/bash

# Script para instalar/actualizar Karpenter con la configuración correcta
# La cola SQS se crea automáticamente por el módulo de Terraform

set -e

# Variables
export KARPENTER_IAM_ROLE_ARN="arn:aws:iam::807867957104:role/firestartr-pre-karpenter-role"
export CLUSTER_NAME="firestartr-pre"
REGION="eu-west-1"

echo "🚀 Instalando/Actualizando Karpenter..."
echo ""
echo "📋 Configuración:"
echo "   - Cluster: ${CLUSTER_NAME}"
echo "   - IAM Role: ${KARPENTER_IAM_ROLE_ARN}"
echo "   - Cola SQS: karpenter-${CLUSTER_NAME}"
echo ""

# Verificar que la cola existe
echo "🔍 Verificando que la cola SQS existe..."
if aws sqs get-queue-url --queue-name "karpenter-${CLUSTER_NAME}" --region "${REGION}" >/dev/null 2>&1; then
    echo "✅ La cola SQS existe: karpenter-${CLUSTER_NAME}"
else
    echo "❌ ERROR: La cola SQS no existe: karpenter-${CLUSTER_NAME}"
    echo ""
    echo "💡 La cola debe ser creada por Terraform antes de instalar Karpenter."
    echo "   Ejecuta 'terraform apply' en el directorio del ejemplo para crear la cola."
    exit 1
fi

echo ""
echo "📦 Instalando Karpenter con Helm..."
aws eks update-kubeconfig --region "${REGION}" --name "${CLUSTER_NAME}"
helm upgrade --install --namespace karpenter --create-namespace \
  karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version 1.6.6 \
  --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=${KARPENTER_IAM_ROLE_ARN}" \
  --set settings.clusterName=${CLUSTER_NAME} \
  --set settings.interruptionQueue=karpenter-${CLUSTER_NAME} \
  --values values.yaml \
  --wait

echo ""
echo "✅ Karpenter instalado/actualizado correctamente"
echo ""
echo "📊 Verificando estado..."
kubectl get pods -n karpenter
echo ""
echo "📋 Verifica los logs para confirmar que no hay errores:"
sleep 15
echo "   kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --tail=50"

