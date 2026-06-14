# workflows

Reusable GitHub Actions for the WPPoland storefront plugin family. Each plugin repo carries only
thin caller workflows that `uses:` these — so adding a new plugin needs ~5 lines of config, not a
CI rebuild. Private repo (callers reference it by `@v1`).

| Reusable workflow | Purpose |
|---|---|
| `_php-ci.yml` | Lint matrix (8.1/8.2/8.3), PHPStan L6, PHPCS, Plugin Check, dependency audit; optional TypeScript, PHPUnit, i18n POT-drift, Playwright CLS smoke (toggled by inputs). |
| `_release-free.yml` | wp.org SVN auto-deploy on a `vX.Y.Z` tag via `10up/action-wordpress-plugin-deploy`. Header==tag gate, `composer install --no-dev` (vendors the kit), POT/MO, changelog-from-readme GitHub release. `dry-run: true` builds the SVN-ready zip as an artifact without pushing. |
| `_release-pro.yml` | Freemius release: build zip (kit + SDK vendored), private GitHub release, Freemius Deploy API upload (signing to be finalized per account). |
| `_pro-boot-smoke.yml` | Boots wp-env with WooCommerce + FREE + PRO; asserts `<slug>/booted` fired. Caller checks out FREE into `./free-plugin` via the workflow input. |

## PRO boot smoke

After changing FREE bootstrap timing, verify PRO still boots in wp-env:

```bash
# Symlink sibling FREE repo, then run from the PRO repo:
ln -sf ../restock restock
PRO_BOOT_FREE_SLUG=restock PRO_BOOT_PRO_SLUG=restock-pro ./scripts/pro-boot-smoke.sh
```

FREE plugins must fire `<slug>/booted` from `Plugin::boot()` on `init` priority 0 (Polski/Restock pattern), not synchronously on `plugins_loaded`.

## Versioning

Callers pin `@v1` (a moving major). Cut immutable `v1.0.0`, `v1.1.0`, … tags and move `v1` to the
latest compatible commit deliberately. Test changes via `workflow_dispatch` on a sacrificial caller
before advancing `v1`.

## Example caller (FREE plugin)

```yaml
# .github/workflows/release.yml in e.g. wppoland/restock
name: Release
on:
  push:
    tags: ['v[0-9]+.[0-9]+.[0-9]+']
jobs:
  release:
    uses: wppoland/workflows/.github/workflows/_release-free.yml@v1
    with:
      slug: restock
      wporg-slug: restock
      has-js: true
    secrets: inherit
```
