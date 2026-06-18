**Mini‑diagrama e notas — Kobo Helm Chart**

- **Diagrama Mermaid:** [docs/architecture.mmd](docs/architecture.mmd)
- **Objetivo:** mostrar conexões principais entre `Enketo`, `KoBoCAT`, `KPI`, `Celery` e infra (Redis, MongoDB, Postgres, Nginx) no deployment Kubernetes gerado pelo Helm chart.

Como visualizar o diagrama:

- No GitHub/GitLab: o arquivo `.mmd` pode ser convertido automaticamente em visualização se o repositório suportar Mermaid; caso contrário, copie o conteúdo para o Mermaid Live Editor: https://mermaid.live/ para renderizar.
- Alternativa local: usar `mmdc` (Mermaid CLI) para gerar PNG/SVG:

```bash
# instalar (Node.js necessário):
npm install -g @mermaid-js/mermaid-cli

# gerar SVG
mmdc -i docs/architecture.mmd -o docs/architecture.svg
```

Mapeamento rápido de onde checar templates no chart:

- Enketo Deployment/Service/Ingress: templates/enketo/
- KoBoCAT/KPI Deployments, Workers, HPA, PDB, Jobs: templates/kpi/
- Configurações e valores: values.yaml

Se quiser, eu posso gerar o SVG localmente e adicioná‑lo ao repositório.
