#!/usr/bin/env bash
# Add .wp-env.json + boot-smoke CI job to storefront *-pro repos.
# Run from workflows repo: bash scripts/propagate-pro-boot-smoke.sh
# Requires sibling dirs under ~/local (or set LOCAL_PLUGINS_ROOT).

set -euo pipefail

ROOT="${LOCAL_PLUGINS_ROOT:-$HOME/local}"

wp_env_json() {
	local free="$1"
	cat <<EOF
{
    "core": null,
    "plugins": [
        "https://downloads.wordpress.org/plugin/woocommerce.zip",
        "./${free}",
        "."
    ],
    "config": {
        "WP_DEBUG": true,
        "WP_DEBUG_LOG": true,
        "WP_DEBUG_DISPLAY": false
    }
}
EOF
}

boot_smoke_block() {
	local free="$1"
	local pro="$2"
	cat <<EOF

  boot-smoke:
    uses: wppoland/workflows/.github/workflows/_pro-boot-smoke.yml@main
    with:
      free-slug: ${free}
      free-repo: wppoland/${free}
      free-ref: main
      pro-slug: ${pro}
EOF
}

PAIRS=(
	sieve-pro:sieve
	tiers-pro:tiers
	marks-pro:marks
	peek-pro:peek
	reel-pro:reel
	versus-pro:versus
	shortlist-pro:shortlist
	swift-pro:swift
	addons-pro:addons
	bundle-pro:bundle
	giftcards-pro:giftcards
)

for pair in "${PAIRS[@]}"; do
	pro="${pair%%:*}"
	free="${pair##*:}"
	dir="${ROOT}/${pro}"
	if [[ ! -d "$dir" ]]; then
		echo "skip ${pro} (no ${dir})"
		continue
	fi

	wp_env_json "$free" > "${dir}/.wp-env.json"
	echo "wrote ${pro}/.wp-env.json"

	ci="${dir}/.github/workflows/ci.yml"
	if [[ ! -f "$ci" ]]; then
		echo "WARN: no ${ci}"
		continue
	fi
	if grep -q 'boot-smoke:' "$ci"; then
		echo "skip ${pro} boot-smoke (already in ci.yml)"
	else
		boot_smoke_block "$free" "$pro" >> "$ci"
		echo "appended boot-smoke to ${pro}/.github/workflows/ci.yml"
	fi
done

echo "Done. Commit workflows (_pro-boot-smoke path fix) and each *-pro repo."
