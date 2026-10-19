#!/usr/bin/env bash
# Assemble GitHub Pages site from main hub + all app/<slug> branches.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SITE="${ROOT}/_site"
mkdir -p "${SITE}/apps"

# Hub from current checkout (main / workflow workspace)
cp "${ROOT}/.nojekyll" "${SITE}/" 2>/dev/null || touch "${SITE}/.nojekyll"
cp "${ROOT}/index.html" "${SITE}/index.html"
cp "${ROOT}/404.html" "${SITE}/404.html"
cp "${ROOT}/hub.css" "${SITE}/hub.css" 2>/dev/null || true
cp "${ROOT}/hub.js" "${SITE}/hub.js" 2>/dev/null || true

# Ensure remotes are available
git fetch --prune origin 2>/dev/null || true

CATALOG="${SITE}/apps/catalog.json"
echo '[' > "${CATALOG}"
first=1

while IFS= read -r ref; do
  [ -z "${ref}" ] && continue
  slug="${ref#origin/app/}"
  # skip template / empty
  if [ "${slug}" = "_template" ] || [ "${slug}" = "${ref}" ]; then
    continue
  fi
  if [[ ! "${slug}" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
    echo "skip invalid slug: ${slug}" >&2
    continue
  fi

  dest="${SITE}/apps/${slug}"
  mkdir -p "${dest}"
  # Export branch tree into apps/<slug>/
  git archive "origin/app/${slug}" | tar -x -C "${dest}"

  # Prefer app.json from branch; synthesize if missing
  meta="${dest}/app.json"
  if [ ! -f "${meta}" ]; then
    cat > "${meta}" <<EOF
{
  "id": "${slug}",
  "title": "${slug}",
  "description": "",
  "version": "",
  "path": "apps/${slug}/"
}
EOF
  fi

  # Ensure redirect page exists
  if [ ! -f "${dest}/index.html" ]; then
    if [ -f "${ROOT}/_shared/redirect.html" ]; then
      cp "${ROOT}/_shared/redirect.html" "${dest}/index.html"
    fi
  fi

  if [ "${first}" -eq 0 ]; then
    echo ',' >> "${CATALOG}"
  fi
  first=0
  # inject path if absent via minimal jq-less pass-through
  python3 - <<PY >> "${CATALOG}"
import json
from pathlib import Path
p = Path(r"${meta}")
data = json.loads(p.read_text(encoding="utf-8"))
data.setdefault("id", "${slug}")
data.setdefault("path", "apps/${slug}/")
print(json.dumps(data, ensure_ascii=False))
PY

  echo "packed app/${slug} → apps/${slug}/"
done < <(git branch -r --list 'origin/app/*' | sed 's/^[* ]*//' | sort)

echo ']' >> "${CATALOG}"
echo "catalog → ${CATALOG}"
ls -la "${SITE}/apps" || true
