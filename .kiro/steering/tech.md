---
inclusion: always
---

# Tech

## Documentation site

Zensical + `zensical-patina`.

- Python 3 + venv (see `requirements.txt`)
- Markdown content under `docs/`
- Nav defined in `zensical.toml` — never encode order in filenames
- Mermaid via `pymdownx.superfences` custom fence
- GitHub Pages via `actionsforge` `zensical-pages-deploy`
- Custom domain: `aws-route53-central-outbound.johna.kiwi` (`docs/CNAME` + johna-kiwi-infra)

## Commands

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/zensical serve   # local preview
.venv/bin/zensical build   # CI builds this via the reusable workflow
```

## Terraform

```bash
cd terraform/accounts/network   # then dev, sandbox
terraform init
terraform validate
# apply/destroy only with operator consent + R53_OUTBOUND_ALLOW_AWS=1
```

- Provider constraint: `hashicorp/aws` **`~> 6.66`** (current lock **6.66.0**; bump all three
  roots together when raising the minor).
- `required_version >= 1.5.0`.
- Local state; `terraform.tfvars` gitignored; commit `*.tfvars.example` and `.terraform.lock.hcl`.

## CI

| Workflow | Purpose |
| --- | --- |
| `docs.yml` | Zensical Pages deploy |
| `terraform-validate.yml` | fmt + validate matrix over three roots |
| `markdown-lint.yml` / `commitmsg-conform.yml` | PR hygiene |
| `auto-merge.yml` | Dependabot |
