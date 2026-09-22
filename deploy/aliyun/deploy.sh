#!/usr/bin/env bash
# ============================================================================
# Graddu 官网阿里云一键部署脚本
# 适用环境：Windows Git Bash / macOS / Linux
# 部署目标：www.graddu.com & graddu.com -> /opt/graddu
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="${SCRIPT_DIR}/server"
LOCAL_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"      # 仓库根 D:/graddu
ENV_FILE="${SCRIPT_DIR}/env.sh"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "缺少配置文件。请先：cp env.example.sh env.sh 然后检查 SERVER_IP"
  exit 1
fi
# shellcheck disable=SC1090
. "${ENV_FILE}"

SERVER_IP="${SERVER_IP:?请在 env.sh 中填写 SERVER_IP}"
SERVER_USER="${SERVER_USER:-root}"
SSH_PORT="${SSH_PORT:-22}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa}"
REMOTE_ROOT="${REMOTE_ROOT:-/opt/graddu}"
SERVER_PORT="${SERVER_PORT:-8082}"
GRADDU_SERVER_NAME="${GRADDU_SERVER_NAME:-www.graddu.com}"
GRADDU_EXTRA_DOMAINS="${GRADDU_EXTRA_DOMAINS:-graddu.com}"
GRADDU_PUBLIC_BASE_URL="${GRADDU_PUBLIC_BASE_URL:-https://${GRADDU_SERVER_NAME}}"
CERTBOT_EMAIL="${CERTBOT_EMAIL:-hjp9221@63.com}"
JAVA_XMX="${JAVA_XMX:-300m}"
GRADDU_MYSQL_ROOT_PASSWORD="${GRADDU_MYSQL_ROOT_PASSWORD:-}"
DB_NAME="${DB_NAME:-official_website}"
DB_USER="${DB_USER:-official_website}"
APP_ADMIN_USERNAME="${APP_ADMIN_USERNAME:-administrator}"
APP_ADMIN_PASSWORD="${APP_ADMIN_PASSWORD:-admin123}"

MODE="full"
case "${1:-}" in
  --prepare)      MODE="prepare" ;;
  --infra)        MODE="infra" ;;
  --build)        MODE="build" ;;
  --deploy-only)  MODE="deploy" ;;
  --status)       MODE="status" ;;
  --clean-source) MODE="clean-source" ;;
  --rollback)     MODE="rollback"; ARG_VALUE="${2:-}" ;;
  --full|"")      MODE="full" ;;
  *) echo "未知参数: $1（支持 --prepare --infra --build --deploy-only --clean-source --status --rollback）" >&2; exit 1 ;;
esac

log()  { printf '\033[0;32m[deploy]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[deploy]\033[0m %s\n' "$*"; }
die()  { printf '\033[0;31m[deploy][ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

REMOTE_HOST="${SERVER_USER}@${SERVER_IP}"
SSH_OPTS=(-p "${SSH_PORT}" -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -o BatchMode=yes)
if [[ -f "${SSH_KEY}" ]]; then SSH_OPTS+=(-i "${SSH_KEY}"); fi
SCP_OPTS=(-P "${SSH_PORT}" -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new -o BatchMode=yes)
if [[ -f "${SSH_KEY}" ]]; then SCP_OPTS+=(-i "${SSH_KEY}"); fi

# ---------------- 工具检查 ----------------
for c in ssh scp tar; do command -v "$c" >/dev/null || die "缺少命令: $c"; done

# ---------------- SSH 连通性 ----------------
log "测试 SSH 连接 ${REMOTE_HOST}:${SSH_PORT} ..."
if ! ssh "${SSH_OPTS[@]}" "${REMOTE_HOST}" "echo ok" >/dev/null 2>&1; then
  die "无法免密登录 ${REMOTE_HOST}，请检查 SSH 密钥配置"
fi
log "SSH 连通，远程主机: $(ssh "${SSH_OPTS[@]}" "${REMOTE_HOST}" 'hostname')"

# ---------------- 上传运维脚本 ----------------
log "同步运维脚本 -> ${REMOTE_ROOT}/scripts/"
ssh "${SSH_OPTS[@]}" "${REMOTE_HOST}" "mkdir -p ${REMOTE_ROOT}/scripts ${REMOTE_ROOT}/config"
scp "${SCP_OPTS[@]}" -q "${SERVER_DIR}"/*.sh "${SERVER_DIR}"/*.conf "${REMOTE_HOST}:${REMOTE_ROOT}/scripts/"
ssh "${SSH_OPTS[@]}" "${REMOTE_HOST}" \
  "sed -i 's/\r$//' ${REMOTE_ROOT}/scripts/*.sh ${REMOTE_ROOT}/scripts/*.conf 2>/dev/null; \
   chmod +x ${REMOTE_ROOT}/scripts/*.sh; echo '脚本权限已就绪'"

# ---------------- 打包源码并上传 ----------------
upload_source() {
  local tar_file="/tmp/graddu-src-$(date +%Y%m%d-%H%M%S).tar.gz"
  log "打包工程源码（排除 node_modules / target / dist / .git 等）..."
  tar -czf "${tar_file}" \
    --exclude='node_modules' \
    --exclude='target' \
    --exclude='.git' \
    --exclude='.idea' \
    --exclude='.vscode' \
    --exclude='dist' \
    --exclude='*.log' \
    -C "${LOCAL_ROOT}" pom.xml src official-website-frontend
  local size; size=$(du -h "${tar_file}" | cut -f1)
  log "源码包大小: ${size}"

  log "上传源码包至服务器..."
  scp "${SCP_OPTS[@]}" -q "${tar_file}" "${REMOTE_HOST}:/tmp/graddu-src.tar.gz"

  log "解压到 ${REMOTE_ROOT}/src ..."
  ssh "${SSH_OPTS[@]}" "${REMOTE_HOST}" \
    "mkdir -p ${REMOTE_ROOT}/src && rm -rf ${REMOTE_ROOT}/src/* && tar -xzf /tmp/graddu-src.tar.gz -C ${REMOTE_ROOT}/src && rm -f /tmp/graddu-src.tar.gz && echo '解压完成'"
  rm -f "${tar_file}"
}

run_remote() {
  local script="$1"; shift
  local env_prefix="" k v
  for kv in "$@"; do
    k="${kv%%=*}"; v="${kv#*=}"
    v="${v//\'/\'\\\'\'}"
    env_prefix+="${k}='${v}' "
  done
  log ">>> 执行远程脚本 ${script} ..."
  # shellcheck disable=SC2029
  ssh "${SSH_OPTS[@]}" "${REMOTE_HOST}" \
    "${env_prefix} GRADDU_ROOT=${REMOTE_ROOT} bash ${REMOTE_ROOT}/scripts/${script}"
}

COMMON_ENVS=(
  "SERVER_PORT=${SERVER_PORT}"
  "GRADDU_SERVER_NAME=${GRADDU_SERVER_NAME}"
  "GRADDU_EXTRA_DOMAINS=${GRADDU_EXTRA_DOMAINS}"
  "GRADDU_PUBLIC_BASE_URL=${GRADDU_PUBLIC_BASE_URL}"
  "CERTBOT_EMAIL=${CERTBOT_EMAIL}"
  "JAVA_XMX=${JAVA_XMX}"
  "GRADDU_MYSQL_ROOT_PASSWORD=${GRADDU_MYSQL_ROOT_PASSWORD}"
  "DB_NAME=${DB_NAME}"
  "DB_USER=${DB_USER}"
  "APP_ADMIN_USERNAME=${APP_ADMIN_USERNAME}"
  "APP_ADMIN_PASSWORD=${APP_ADMIN_PASSWORD}"
)

case "${MODE}" in
  prepare)
    run_remote 01-prepare-server.sh
    ;;
  infra)
    run_remote 02-init-infra.sh "${COMMON_ENVS[@]}"
    ;;
  build)
    upload_source
    run_remote 03-build.sh
    ;;
  deploy)
    run_remote 04-deploy.sh "${COMMON_ENVS[@]}"
    ;;
  status)
    run_remote 06-status.sh
    ;;
  clean-source)
    ssh "${SSH_OPTS[@]}" "${REMOTE_HOST}" "rm -rf ${REMOTE_ROOT}/src /tmp/graddu-src*.tar.gz 2>/dev/null && echo '✅ 源码已清除'"
    ;;
  rollback)
    run_remote "05-rollback.sh ${ARG_VALUE:-}"
    ;;
  full)
    if [[ "${SKIP_PREPARE:-no}" != "yes" ]]; then
      run_remote 01-prepare-server.sh
    else
      log "SKIP_PREPARE=yes，跳过系统环境初始化"
      ssh "${SSH_OPTS[@]}" "${REMOTE_HOST}" "mkdir -p ${REMOTE_ROOT}/{src,app,releases,www,logs,config,scripts,backups,data/uploads}"
    fi
    upload_source
    run_remote 02-init-infra.sh "${COMMON_ENVS[@]}"
    run_remote 03-build.sh
    run_remote 04-deploy.sh "${COMMON_ENVS[@]}"
    ;;
esac

if [[ "${MODE}" == "full" || "${MODE}" == "deploy" ]]; then
  cat <<EOF

$(printf '\033[0;32m[deploy]\033[0m') Graddu 官网部署完成！
  官方主页: ${GRADDU_PUBLIC_BASE_URL}/
  备用域名: https://${GRADDU_EXTRA_DOMAINS}/
  管理后台: ${GRADDU_PUBLIC_BASE_URL}/console/login
  默认管理员: ${APP_ADMIN_USERNAME} / ${APP_ADMIN_PASSWORD}
  
  查看状态命令: bash deploy/aliyun/deploy.sh --status
  回滚版本命令: bash deploy/aliyun/deploy.sh --rollback
EOF
fi
