#!/usr/bin/env bash
# ============================================================================
# Graddu 官网服务器环境检查与骨架创建
# 部署根路径：/opt/graddu
# 用法：sudo bash /opt/graddu/scripts/01-prepare-server.sh
# ============================================================================
set -euo pipefail

GRADDU_ROOT="${GRADDU_ROOT:-/opt/graddu}"
LOG_DIR="${GRADDU_ROOT}/logs"

export DEBIAN_FRONTEND=noninteractive
export LANG=C.UTF-8

log()  { printf '\033[0;32m[prepare]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[prepare]\033[0m %s\n' "$*"; }
die()  { printf '\033[0;31m[prepare][ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "请用 root 执行（sudo bash $0）"

# ---------------- 目录骨架 ----------------
log "创建目录骨架 ${GRADDU_ROOT}/..."
mkdir -p "${GRADDU_ROOT}"/{src,app,releases,www,logs,config,scripts,backups,data/uploads}
if [[ ! -f "${GRADDU_ROOT}/data/downloads.json" ]]; then
  echo "[]" > "${GRADDU_ROOT}/data/downloads.json"
fi
chmod 755 "${GRADDU_ROOT}"
chmod -R 755 "${GRADDU_ROOT}/data"

# 检查基础组件
for cmd in java mvn node npm nginx mysql; do
  if command -v "$cmd" >/dev/null 2>&1; then
    log "已就绪组件: $cmd ($(command -v "$cmd"))"
  else
    warn "缺失组件: $cmd"
  fi
done

log "✅ Graddu 官网服务器骨架准备完毕 (/opt/graddu)"
