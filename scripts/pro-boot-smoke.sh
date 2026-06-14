#!/usr/bin/env bash
# Verify FREE+PRO boot wiring in a running wp-env instance.
#
# Usage (from a PRO plugin repo with wp-env mapping FREE + PRO):
#   PRO_BOOT_FREE_SLUG=restock PRO_BOOT_PRO_SLUG=restock-pro ./scripts/pro-boot-smoke.sh
#
# Requires: npx @wordpress/env, WooCommerce + both plugins activated.

set -euo pipefail

FREE_SLUG="${PRO_BOOT_FREE_SLUG:?Set PRO_BOOT_FREE_SLUG (e.g. restock)}"
PRO_SLUG="${PRO_BOOT_PRO_SLUG:?Set PRO_BOOT_PRO_SLUG (e.g. restock-pro)}"
BOOT_ACTION="${FREE_SLUG}/booted"
WP_ENV_RUN=(npx --yes @wordpress/env@^10 run cli wp)

echo "==> Activating WooCommerce, ${FREE_SLUG}, ${PRO_SLUG}"
"${WP_ENV_RUN[@]}" plugin activate woocommerce "${FREE_SLUG}" "${PRO_SLUG}"

echo "==> Checking ${BOOT_ACTION} fired"
"${WP_ENV_RUN[@]}" eval "
if ( ! did_action( '${BOOT_ACTION}' ) ) {
	fwrite( STDERR, 'FAIL: ${BOOT_ACTION} did not fire after boot.' . PHP_EOL );
	exit( 1 );
}
echo 'OK: ${BOOT_ACTION} fired.' . PHP_EOL;
"

echo "==> PRO boot smoke passed"
