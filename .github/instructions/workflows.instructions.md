---
applyTo: ".github/workflows/**"
---
# GitHub Actions workflows

- Keep `permissions` at the minimum each job needs; the workflow default is `contents: read`.
- The Flutter version is set by the `FLUTTER_VERSION` env var in `ci.yml`. Keep
  `copilot-setup-steps.yml` on the same version.
- Don't rename CI jobs. Their names are required status checks in the `main` ruleset.
- Feature PRs shouldn't modify workflows unless the approved plan says so.
