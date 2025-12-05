# 🚀 Karpenter - Auto-scaling de Nodos en EKS

Este directorio contiene la configuración completa para instalar y usar Karpenter en tu cluster EKS.

---

## 📚 ¿Qué es Karpenter?

**Karpenter** es un auto-scaler de nodos para Kubernetes que:
- ✅ **Crea nodos automáticamente** cuando hay pods pendientes
- ✅ **Elimina nodos** cuando están vacíos o subutilizados (consolidation)
- ✅ **Optimiza costos** eligiendo el tipo de instancia más adecuado
- ✅ **Reacciona rápido** (segundos, no minutos como Cluster Autoscaler)

---

``

### Componentes Clave

| Componente | Descripción | Archivo |
|------------|-------------|---------|
| **Karpenter Controller** | Pod que gestiona el auto-scaling | Instalado con Helm |
| **NodePool** | Define qué nodos puede crear (labels, taints, tipos de instancia) | `karpenter-dev-v1.yaml` |
| **EC2NodeClass** | Define infraestructura AWS (AMI, subnets, security groups) | `karpenter-on-demand-default-v1.yaml` |
| **Pod** | Tu aplicación que necesita recursos | `deployment-dev.yaml` |

---

## 📦 Instalación

### Paso 1: Instalar Karpenter con Helm

```bash
cd /home/pablo/prefapp/tfm/modules/aws-eks/_examples/test_karpenter/yamls_karpenter
chmod +x *.sh
./instalar-karpenter.sh
```

**¿Qué hace este script?**
1. Verifica que la cola SQS existe (creada por Terraform)
2. Instala Karpenter con Helm usando `values.yaml`
3. Configura el ServiceAccount con el IAM role correcto
4. Configura el nombre del cluster y la cola SQS

**Archivos usados:**
- `values.yaml` → Configuración del chart de Helm
- `instalar-karpenter.sh` → Script de instalación

### Paso 2: Aplicar NodePools

Los **NodePools** le dicen a Karpenter qué tipo de nodos puede crear.

```bash
# Aplicar EC2NodeClass y NodePool base (requerido)
kubectl apply -f karpenter-on-demand-default-v1.yaml

# Aplicar NodePool para dev
kubectl apply -f karpenter-dev-v1.yaml
```

**¿Qué hace cada archivo?**

#### `karpenter-on-demand-default-v1.yaml`
- Define el **EC2NodeClass** (infraestructura AWS compartida)
- Define un **NodePool** genérico sin taints
- **Requerido** porque otros NodePools lo referencian

#### `karpenter-dev-v1.yaml`
- Define un **NodePool** específico para desarrollo
- Tiene **taint** `environment=dev:NoSchedule`
- Solo pods con toleration pueden ejecutarse aquí

### Paso 3: (Opcional) Aplicar Deployment de Ejemplo

```bash
kubectl apply -f deployment-dev.yaml
```

Este deployment tiene:
- **nodeSelector**: `environment: dev` → Dirige el pod a nodos con ese label
- **tolerations**: Permite ejecutarse en nodos con taint `environment=dev:NoSchedule`

---

## 🔄 ¿Cómo Funciona el Auto-scaling?

### Escenario: Desplegar un Pod que Necesita un Nodo

#### 1. Ejemplo de un Pod

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mi-app
spec:
  replicas: 3
  template:
    spec:
      nodeSelector:
        environment: dev  # ← Requiere nodo con este label
      tolerations:
        - key: environment
          value: dev
          effect: NoSchedule  # ← Permite ejecutarse en nodos con este taint
      containers:
      - name: app
        resources:
          requests:
            cpu: "1000m"
            memory: "1Gi"
```


#### 2. Karpenter Detecta el Pod Pendiente

Karpenter escanea continuamente los pods en estado `Pending` y analiza:
- **Requisitos del pod**: CPU, memoria, nodeSelector, tolerations

#### 3. Karpenter Selecciona un NodePool

Karpenter evalúa los NodePools según:
1. **Weight** (prioridad): Mayor = más prioridad
2. **Requirements**: ¿El NodePool puede crear nodos que cumplan los requisitos del pod?
3. **Costo**: Entre opciones válidas, elige la más económica

En nuestro caso:
- Pod requiere: `environment: dev` + toleration para `environment=dev:NoSchedule`
- NodePool `karpenter-dev` tiene:
  - Label: `environment: dev` ✅
  - Taint: `environment=dev:NoSchedule` ✅
  - Tipos de instancia: `m6a.large`, `m6a.xlarge` (suficiente para 1 CPU, 1Gi RAM) ✅
- **Resultado**: Karpenter selecciona `karpenter-dev`

#### 4. Karpenter Crea una Instancia EC2

Karpenter usa el **EC2NodeClass** referenciado por el NodePool:
- **AMI**: Amazon Linux 2023 (según `amiSelectorTerms`)
- **Subnets**: Subnets privadas (según `subnetSelectorTerms`)
- **Security Groups**: `kubernetes-my-org-dev-node` (según `securityGroupSelectorTerms`)
- **IAM Role**: `Karpenter-kubernetes-my-org-dev`
- **Storage**: 100Gi gp3 encrypted

Karpenter elige el tipo de instancia más pequeño que pueda alojar el pod:
- Pod necesita: 1 CPU, 1Gi RAM
- Opciones: `m6a.large` (2 vCPU, 8Gi RAM) o `m6a.xlarge` (4 vCPU, 16Gi RAM)
- **Elige**: `m6a.large` (más económico y suficiente)

#### 5. La Instancia se Une al Cluster

La instancia EC2:
1. Se inicia con el script de bootstrap de EKS
2. Se une al cluster como nodo
3. Recibe los labels y taints del NodePool:
   - Label: `environment: dev`
   - Taint: `environment=dev:NoSchedule`

#### 6. Kubernetes Programa el Pod

```bash
kubectl get pods
# NAME      READY   STATUS    NODES
# mi-app-1  1/1     Running   ip-10-1-19-235.eu-west-1.compute.internal  ← En el nuevo nodo
```

---

## 🎯 Configuración de NodePools

### ¿Cómo Configurar un NodePool para que Karpenter lo Use?

Un NodePool debe cumplir los requisitos del pod para ser seleccionado:

#### 1. Labels y Taints

```yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: karpenter-dev
spec:
  template:
    metadata:
      labels:
        environment: dev  # ← Los pods con nodeSelector "environment: dev" irán aquí
    spec:
      taints:
        - key: environment
          value: dev
          effect: NoSchedule  # ← Solo pods con toleration pueden ejecutarse
```

#### 2. Requirements (Tipos de Instancia)

```yaml
spec:
  template:
    spec:
      requirements:
        - key: node.kubernetes.io/instance-type
          operator: In
          values:
          - m6a.large
          - m6a.xlarge
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
```

#### 3. NodeClassRef (Infraestructura)

```yaml
spec:
  template:
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: karpenter-on-demand-default  # ← Referencia al EC2NodeClass
```

#### 4. Weight (Prioridad)

```yaml
spec:
  weight: 10  # ← Mayor = más prioridad cuando varios NodePools pueden satisfacer el pod
```
---

## 🗑️ Desinstalación

```bash
./desinstalar-karpenter.sh
```

Este script:
1. Elimina los deployments de ejemplo
2. Elimina los NodePools (esto hace que Karpenter elimine los nodos)
3. Desinstala Karpenter con Helm

---

## 📋 Archivos del Directorio

| Archivo | Descripción |
|---------|-------------|
| `values.yaml` | Configuración del chart de Helm para Karpenter |
| `instalar-karpenter.sh` | Script para instalar Karpenter |
| `aplicar-configuracion.sh` | Script que instala todo (Karpenter + NodePools + Deployment) |
| `desinstalar-karpenter.sh` | Script para desinstalar Karpenter |
| `karpenter-on-demand-default-v1.yaml` | EC2NodeClass + NodePool base |
| `karpenter-dev-v1.yaml` | NodePool para nodos de desarrollo |
| `deployment-dev.yaml` | Deployment de ejemplo que usa nodos de dev |

---

## 💡 Conceptos Clave

### NodePool vs EC2NodeClass

- **NodePool**: Define **qué** nodos puede crear (labels, taints, tipos de instancia, límites)
- **EC2NodeClass**: Define **cómo** crear los nodos (AMI, subnets, security groups, IAM, storage)

**Puedes tener:**
- Múltiples NodePools usando el mismo EC2NodeClass (comparten infraestructura)
- Un NodePool usando un EC2NodeClass específico

### Taints y Tolerations

- **Taint**: "Este nodo solo acepta pods con toleration específica"
- **Toleration**: "Este pod puede ejecutarse en nodos con este taint"

**Ejemplo:**
- NodePool tiene taint: `environment=dev:NoSchedule`
- Pod necesita toleration: `environment=dev:NoSchedule`
- **Resultado**: El pod puede ejecutarse en el nodo

### NodeSelector vs NodeAffinity

- **NodeSelector**: Simple, solo igualdad exacta
- **NodeAffinity**: Más flexible, permite operadores (`In`, `NotIn`, `Exists`, etc.)

**Ejemplo NodeSelector:**
```yaml
nodeSelector:
  environment: dev
```

**Ejemplo NodeAffinity:**
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: environment
          operator: In
          values: ["dev", "pre"]
```

---

## 🚀 Uso Rápido

```bash
# Instalar todo
./aplicar-configuracion.sh

# Desinstalar
./desinstalar-karpenter.sh
```

---

## 📚 Más Información

- [Documentación oficial de Karpenter](https://karpenter.sh/)
- [NodePools](https://karpenter.sh/docs/concepts/nodepools/)
- [EC2NodeClass](https://karpenter.sh/docs/concepts/nodeclasses/)
