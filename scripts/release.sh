#!/usr/bin/env bash
# Builds a release bundle into dist/.   Usage: scripts/release.sh vMAJOR.MINOR.PATCH   (or: make release VERSION=v0.1.0)
# Used by .github/workflows/release.yml; can be run locally. It never deploys and never contacts GitHub.
#
# dist/ gets: deploy-bundle-<version>.tar.gz, release-manifest.json, SHA256SUMS (of those two files).
# The bundle holds: images.tar, release-manifest.json, sbom/, deploy/, migrations/, SHA256SUMS (verified by deploy.sh).
# TODO: SBOMs cover the Go module and the npm lockfile only, not the container images (list as a known gap).
set -euo pipefail
cd "$(dirname "$0")/.."

version="${1:-}"
[[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.]+)?$ ]] || { echo "usage: $0 vMAJOR.MINOR.PATCH" >&2; exit 2; }
for cmd in docker jq git sha256sum tar go node npm; do command -v "$cmd" >/dev/null || { echo "missing tool: $cmd" >&2; exit 1; }; done

rm -rf dist/bundle dist/deploy-bundle-*.tar.gz dist/release-manifest.json dist/SHA256SUMS
mkdir -p dist/bundle/sbom

echo "== build images"
docker build -q -f api/Dockerfile --target api     -t "bappelitbangda-api:${version}" .
docker build -q -f api/Dockerfile --target migrate -t "bappelitbangda-migrate:${version}" .
docker build -q -f web/Dockerfile                  -t "bappelitbangda-web:${version}" web

# Base images referenced by deploy/docker-compose.yml (pinned by digest there).
mapfile -t base_images < <(grep -oE 'image: (nginx|postgres):[^ ]+' deploy/docker-compose.yml | awk '{print $2}' | sort -u)
for img in "${base_images[@]}"; do docker pull -q "$img" >/dev/null; done

echo "== save images"
docker save --output dist/bundle/images.tar \
  "bappelitbangda-api:${version}" "bappelitbangda-migrate:${version}" "bappelitbangda-web:${version}" "${base_images[@]}"

echo "== SBOMs (Go module, npm lockfile)"
(cd tools && go tool cyclonedx-gomod mod -json -output ../dist/bundle/sbom/api.cdx.json ../api)
(cd web && npm sbom --sbom-format cyclonedx --omit dev --package-lock-only > ../dist/bundle/sbom/web.cdx.json)

echo "== manifest"
img_id() { docker image inspect --format '{{.Id}}' "$1"; }
highest_migration="$(find api/db/migrations -name '*.sql' -printf '%f\n' | sort | tail -n 1)"
jq -n \
  --arg version "$version" \
  --arg sha "$(git rev-parse HEAD)" \
  --arg api "$(img_id "bappelitbangda-api:${version}")" \
  --arg web "$(img_id "bappelitbangda-web:${version}")" \
  --arg migrate "$(img_id "bappelitbangda-migrate:${version}")" \
  --arg tar "$(sha256sum dist/bundle/images.tar | cut -d' ' -f1)" \
  --arg mig "$highest_migration" \
  --arg go "$(go version)" --arg node "$(node --version)" --arg docker "$(docker --version)" \
  --argjson base "$(printf '%s\n' "${base_images[@]}" | jq -R . | jq -s .)" \
  '{version:$version, git_sha:$sha,
    images:{api:{id:$api}, web:{id:$web}, migrate:{id:$migrate}},
    base_images:$base, images_tar_sha256:$tar, highest_migration:$mig,
    tools:{go:$go, node:$node, docker:$docker}}' > dist/bundle/release-manifest.json

echo "== assemble bundle"
cp -r deploy dist/bundle/deploy
cp -r api/db/migrations dist/bundle/migrations
# shellcheck disable=SC2094  # SHA256SUMS is excluded from the file list
( cd dist/bundle && find . -type f ! -name SHA256SUMS | sort | sed 's|^\./||' | xargs sha256sum > SHA256SUMS )
tar --sort=name --owner=0 --group=0 --numeric-owner -C dist/bundle -czf "dist/deploy-bundle-${version}.tar.gz" .
cp dist/bundle/release-manifest.json dist/release-manifest.json
( cd dist && sha256sum "deploy-bundle-${version}.tar.gz" release-manifest.json > SHA256SUMS )

echo "== done"
ls -l dist/deploy-bundle-"${version}".tar.gz dist/release-manifest.json dist/SHA256SUMS
