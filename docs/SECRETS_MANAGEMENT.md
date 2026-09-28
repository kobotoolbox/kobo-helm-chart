# Secrets Management Guide

## Overview

Este chart foi refatorado para suportar dois padrões de gerenciamento de secrets:

1. **ExistingSecret Pattern** (Recomendado para Produção) - Referencia um secret pré-criado
2. **Generated Secrets** (Padrão antigo) - O chart cria secrets automaticamente

## ExistingSecret Pattern (Recomendado)

### Vantagens

✅ Secrets não ficam versionados no chart  
✅ Separação clara entre infraestrutura e configuração  
✅ Compatible com ferramentas como Sealed Secrets, External Secrets Operator  
✅ Workflow seguro para CI/CD  

### Como Usar

#### 1. Criar o Secret

```bash
# Opção 1: Criar manualmente
kubectl create secret generic kobo-secrets \
  --from-literal=DJANGO_SECRET_KEY="your-secure-django-secret" \
  --from-literal=ENKETO_API_KEY="your-enketo-api-key" \
  -n kobo-namespace
```

```bash
# Opção 2: Usar arquivo
cat <<EOF > secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: kobo-secrets
  namespace: kobo-namespace
type: Opaque
stringData:
  DJANGO_SECRET_KEY: "your-secure-django-secret"
  ENKETO_API_KEY: "your-enketo-api-key"
EOF

kubectl apply -f secrets.yaml
```

#### 2. Configurar o values.yaml ou values-prod.yaml

```yaml
kobotoolbox:
  secrets:
    existingSecret: "kobo-secrets"
    djangoSecretKeyField: "DJANGO_SECRET_KEY"
    enketoApiKeyField: "ENKETO_API_KEY"
```

#### 3. Deploy

```bash
helm install kobo ./kobo \
  -f values-prod.yaml \
  -n kobo-namespace
```

## Generated Secrets (Padrão Antigo)

### Quando Usar

❌ Desenvolvimento/Testes local  
❌ NÃO recomendado para produção  

### Como Usar

Se **não** especificar `existingSecret`, o chart criará secrets automaticamente:

```yaml
kobotoolbox:
  secrets:
    existingSecret: ""  # Deixar vazio para gerar secrets
```

> **⚠️ AVISO**: Os secrets gerados pelo chart estarão armazenados no etcd do Kubernetes em texto plano (base64-encoded). Não é seguro para produção.

## Campos de Secrets Suportados

### Secret KPI (`kobo-secrets`)

| Campo | Descrição | Obrigatório |
|-------|-----------|------------|
| `DJANGO_SECRET_KEY` | Secret key do Django | ✅ Sim |
| `ENKETO_API_KEY` | API key do Enketo | ✅ Sim |
| `KC_DATABASE_URL` | URL do banco PostgreSQL (se externo) | ❌ Opcional |
| `MONGO_DB_URL` | URL do MongoDB (se externo) | ❌ Opcional |
| `REDIS_SESSION_URL` | URL do Redis Session (se externo) | ❌ Opcional |

### Variáveis Adicionais

Você pode adicionar qualquer variável ao secret e ela será carregada automaticamente via `envFrom: secretRef`.

## Integração com External Secrets Operator (ESO)

Se sua infraestrutura usa External Secrets Operator para sincronizar secrets de um vault externo (Vault, AWS Secrets Manager, etc):

```yaml
---
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
  namespace: kobo-namespace
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "kobo"
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: kobo-secrets
  namespace: kobo-namespace
spec:
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: kobo-secrets
    creationPolicy: Owner
  data:
    - secretKey: DJANGO_SECRET_KEY
      remoteRef:
        key: kobo/django_secret_key
    - secretKey: ENKETO_API_KEY
      remoteRef:
        key: kobo/enketo_api_key
```

Então configure:

```yaml
kobotoolbox:
  secrets:
    existingSecret: "kobo-secrets"
```

## Migração de Produção Existente

Se você tem um deployment anterior com secrets inline:

```bash
# 1. Criar um backup dos secrets atuais
kubectl get secret kobo-kpi -n kobo-namespace -o yaml > kobo-kpi-backup.yaml

# 2. Criar o novo secret com os valores antigos
kubectl create secret generic kobo-secrets \
  --from-literal=DJANGO_SECRET_KEY="$ANTIGO_DJANGO_SECRET" \
  --from-literal=ENKETO_API_KEY="$ANTIGO_ENKETO_API_KEY" \
  -n kobo-namespace

# 3. Atualizar o values.yaml do deployment
# Adicionar a configuração do existingSecret

# 4. Fazer o upgrade
helm upgrade kobo ./kobo \
  -f values-prod.yaml \
  -n kobo-namespace

# 5. Remover secrets antigos (se necessário)
kubectl delete secret kobo-kpi kobo-enketo -n kobo-namespace
```

## Troubleshooting

### Secret não encontrado

```bash
# Verificar se o secret existe
kubectl get secret kobo-secrets -n kobo-namespace

# Verificar conteúdo
kubectl describe secret kobo-secrets -n kobo-namespace
```

### Pod não inicia

```bash
# Verificar logs
kubectl logs -n kobo-namespace deployment/kobo-kpi

# Procurar por erros de secret mounting
kubectl describe pod -n kobo-namespace -l app.kubernetes.io/name=kobo
```

### Verificar qual secret está sendo usado

```bash
kubectl get deployment kobo-kpi -n kobo-namespace -o yaml | grep secretRef
```

## Boas Práticas

1. **Nunca commitar secrets** no Git
2. **Usar RBAC** para limitar acesso aos secrets
3. **Rotacionar secrets regularmente** (pelo menos 1x por ano)
4. **Usar tools para gerenciar secrets**:
   - Sealed Secrets
   - External Secrets Operator
   - HashiCorp Vault
   - AWS Secrets Manager
5. **Backup secrets com segurança** offline
6. **Audit logs** para acesso aos secrets

## Referências

- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [External Secrets Operator](https://external-secrets.io/)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [HashiCorp Vault](https://www.vaultproject.io/)
