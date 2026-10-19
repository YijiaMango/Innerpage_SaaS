#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SITE="${ROOT}/_site"
rm -rf "${SITE}"
mkdir -p "${SITE}"

cp "${ROOT}/.nojekyll" "${SITE}/" 2>/dev/null || touch "${SITE}/.nojekyll"
cp "${ROOT}/index.html" "${SITE}/index.html"
cp "${ROOT}/404.html" "${SITE}/404.html"
cp "${ROOT}/hub.css" "${SITE}/hub.css" 2>/dev/null || true
cp "${ROOT}/hub.js" "${SITE}/hub.js" 2>/dev/null || true
cp "${ROOT}/YijiaMango.png" "${SITE}/YijiaMango.png" 2>/dev/null || true

git fetch --prune origin 2>/dev/null || true

CATALOG="${SITE}/catalog.json"
echo '[' > "${CATALOG}"
first=1

is_reserved() {
  case "$1" in
    index|404|hub|catalog|_shared|scripts|.github) return 0 ;;
    *) return 1 ;;
  esac
}

while IFS= read -r ref; do
  [ -z "${ref}" ] && continue
  slug="${ref#origin/app/}"
  if [ "${slug}" = "_template" ] || [ "${slug}" = "${ref}" ]; then
    continue
  fi
  if [[ ! "${slug}" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
    continue
  fi
  if is_reserved "${slug}"; then
    continue
  fi

  dest="${SITE}/${slug}"
  mkdir -p "${dest}"
  git archive "origin/app/${slug}" | tar -x -C "${dest}"

  meta="${dest}/app.json"
  if [ ! -f "${meta}" ]; then
    cat > "${meta}" <<EOF
{
  "id": "${slug}",
  "title": "${slug}",
  "description": "",
  "version": "",
  "path": "${slug}/"
}
EOF
  fi

  if [ ! -f "${dest}/index.html" ] && [ -f "${ROOT}/_shared/redirect.html" ]; then
    cp "${ROOT}/_shared/redirect.html" "${dest}/index.html"
  fi

  if [ "${first}" -eq 0 ]; then
    echo ',' >> "${CATALOG}"
  fi
  first=0
  python3 - <<PY >> "${CATALOG}"
import json
from pathlib import Path
p = Path(r"${meta}")
data = json.loads(p.read_text(encoding="utf-8-sig"))
data["id"] = "${slug}"
data["path"] = "${slug}/"
print(json.dumps(data, ensure_ascii=False))
PY
done < <(git branch -r --list 'origin/app/*' | sed 's/^[* ]*//' | sort)

echo ']' >> "${CATALOG}"
