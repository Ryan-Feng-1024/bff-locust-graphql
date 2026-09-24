#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
SKILL_VALIDATOR="${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py"

for required in SKILL.md agents/openai.yaml VERSION CHANGELOG.md LICENSE README.md; do
  if [ ! -f "$ROOT_DIR/$required" ]; then
    echo "缺少发布文件: $required" >&2
    exit 1
  fi
done

if [ ! -f "$SKILL_VALIDATOR" ]; then
  echo "找不到 Skill 校验器: $SKILL_VALIDATOR" >&2
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "uv 未安装，无法运行 Skill 校验。" >&2
  exit 127
fi

uv run --with pyyaml python "$SKILL_VALIDATOR" "$ROOT_DIR"

if grep -R -n -E 'TODO|PLACEHOLDER' "$ROOT_DIR/SKILL.md" "$ROOT_DIR/references"; then
  echo "发现未完成的占位内容。" >&2
  exit 1
fi

echo "Release validation passed: $(cat "$ROOT_DIR/VERSION")"
