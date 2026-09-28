# ExistingSecret Pattern - Resumo das Mudanças

## ✅ Mudanças Implementadas

### 1. **values.yaml**
Adicionada nova seção de configuração de secrets:

```yaml
kobotoolbox:
  secrets:
    existingSecret: ""                    # Nome do secret a referenciar
    djangoSecretKeyField: "DJANGO_SECRET_KEY"
    enketoApiKeyField: "ENKETO_API_KEY"
```

### 2. **templates/kpi/secrets.yaml**
- Removida linha: `DJANGO_SECRET_KEY: {{ .Values.kobotoolbox.djangoSecret | ... }}`
- Removida linha: `ENKETO_API_KEY: {{ required "..." .Values.kobotoolbox.enketoApiKey | ... }}`
- Adicionada lógica condicional: `{{- if not .Values.kobotoolbox.secrets.existingSecret }}`
- **Resultado**: Secret é criado APENAS se `existingSecret` está vazio

### 3. **templates/enketo/secrets.yaml**
- Removida linha: `ENKETO_LINKED_FORM_AND_DATA_SERVER_API_KEY: {{ required "..." }}`
- Adicionada lógica condicional: `{{- if not .Values.kobotoolbox.secrets.existingSecret }}`
- **Resultado**: Secret é criado APENAS se `existingSecret` está vazio

### 4. **templates/_helpers.tpl**
Adicionados dois novos helpers:

```go-template
{{- define "kobo.kpi.secretName" -}}
  {{- if .Values.kobotoolbox.secrets.existingSecret -}}
    {{- .Values.kobotoolbox.secrets.existingSecret -}}
  {{- else -}}
    {{- include "kobo.fullname" . }}-kpi
  {{- end -}}
{{- end -}}

{{- define "kobo.enketo.secretName" -}}
  {{- if .Values.kobotoolbox.secrets.existingSecret -}}
    {{- .Values.kobotoolbox.secrets.existingSecret -}}
  {{- else -}}
    {{- include "kobo.fullname" . }}-enketo
  {{- end -}}
{{- end -}}
```

### 5. **docs/SECRETS_MANAGEMENT.md** ✨ NOVO
Documento completo com:
- Guia passo-a-passo para criar secrets
- Exemplos de configuração
- Integração com External Secrets Operator (ESO)
- Migração de deployments existentes
- Troubleshooting
- Boas práticas de segurança

---

## 🔄 Fluxo de Funcionamento

### Cenário 1: Using Existing Secret (Produção - Recomendado)

```
1. Admin cria secret manualmente:
   kubectl create secret generic kobo-secrets \
     --from-literal=DJANGO_SECRET_KEY=xxx \
     --from-literal=ENKETO_API_KEY=yyy

2. values-prod.yaml:
   kobotoolbox:
     secrets:
       existingSecret: "kobo-secrets"

3. Helm deploy:
   helm install kobo ./kobo -f values-prod.yaml

4. Resultado:
   ✅ Deployments usam secret "kobo-secrets"
   ✅ Novos secrets NÃO são criados
   ✅ Secrets nunca ficam no Git
```

### Cenário 2: Generated Secrets (Desenvolvimento)

```
1. values-dev.yaml:
   kobotoolbox:
     secrets:
       existingSecret: ""

2. Helm deploy:
   helm install kobo ./kobo -f values-dev.yaml

3. Resultado:
   ✅ Chart cria secrets "kobo-kpi" e "kobo-enketo"
   ❌ Mas não é seguro para produção
```

---

## 🎯 Como Deployments Agora Usam os Secrets

### Antes
```yaml
envFrom:
  - secretRef:
      name: kobo-kpi  # Nome hardcoded, criado pelo chart
```

### Depois
Os deployments precisam ser atualizados para usar o helper:
```yaml
envFrom:
  - secretRef:
      name: {{ include "kobo.kpi.secretName" . }}  # Flexível!
```

**Status**: Helpers já estão criados, mas deployments ainda precisam ser atualizados (próximo passo).

---

## 📋 Checklist de Próximos Passos

- [ ] Atualizar `templates/kpi/deployment.yaml` para usar `kobo.kpi.secretName`
- [ ] Atualizar `templates/kpi/migration-job.yaml` para usar `kobo.kpi.secretName`
- [ ] Atualizar `templates/kpi/deployment-*.yaml` (beat, worker, etc) para usar `kobo.kpi.secretName`
- [ ] Atualizar `templates/enketo/deployment.yaml` para usar `kobo.enketo.secretName`
- [ ] Remover Bitnami dependencies do Chart.yaml
- [ ] Criar template exemplo para PostgreSQL Operator
- [ ] Criar arquivo de valores exemplo (`values-prod.yaml`)
- [ ] Testes de deployment em staging

---

## 🚀 Próxima Fase

A próxima fase será **atualizar os deployments** para usar os helpers de secret name, permitindo que eles referenciem o existingSecret corretamente quando configurado.

