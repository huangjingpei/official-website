#!/usr/bin/env bash
# ============================================================================
# Graddu 官网基础设施初始化 —— 生成 .env 配置 / 创建 MySQL 数据库
#
# 幂等设计：
#   - /opt/graddu/.env 已存在则不覆盖
# 用法：sudo bash /opt/graddu/scripts/02-init-infra.sh
# ============================================================================
set -euo pipefail

GRADDU_ROOT="${GRADDU_ROOT:-/opt/graddu}"
ENV_FILE="${GRADDU_ROOT}/.env"
DB_NAME="${DB_NAME:-official_website}"
DB_APP_USER="${DB_USER:-official_website}"

log()  { printf '\033[0;32m[infra]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[infra]\033[0m %s\n' "$*"; }
die()  { printf '\033[0;31m[infra][ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "请用 root 执行（sudo bash $0）"

rand_pass() { openssl rand -base64 30 | tr -dc 'A-Za-z0-9' | head -c 24; }

# ================================================================ 1. 环境文件
if [[ -f "${ENV_FILE}" ]]; then
  log ".env 已存在，保持现有配置"
else
  log "生成 ${ENV_FILE} ..."
  DB_PASSWORD=$(rand_pass)
  cat > "${ENV_FILE}" <<EOF
# ============================================================================
# Graddu 官网生产环境变量
# ============================================================================
TZ=Asia/Shanghai
SERVER_PORT=${SERVER_PORT:-8082}
SERVER_ADDRESS=127.0.0.1
SPRING_APPLICATION_NAME=official-website-backend

# ---- MySQL 数据库配置 ----
MYSQL_URL=jdbc:mysql://127.0.0.1:3306/${DB_NAME}?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true&createDatabaseIfNotExist=true
MYSQL_USERNAME=${DB_APP_USER}
MYSQL_PASSWORD=${DB_PASSWORD}

# ---- 管理员初始化账号 ----
APP_ADMIN_USERNAME=${APP_ADMIN_USERNAME:-administrator}
APP_ADMIN_PASSWORD=${APP_ADMIN_PASSWORD:-admin123}

# ---- 存储路径 ----
APP_STORAGE_UPLOAD_DIR=${GRADDU_ROOT}/data/uploads
APP_STORAGE_METADATA_FILE=${GRADDU_ROOT}/data/downloads.json

# ---- JVM 调优参数 ----
JAVA_OPTS="-Xms128m -Xmx${JAVA_XMX:-300m} -XX:MaxMetaspaceSize=128m -XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${GRADDU_ROOT}/logs -Dfile.encoding=UTF-8 -Dsun.stdout.encoding=UTF-8 -Dsun.stderr.encoding=UTF-8"
EOF
  chmod 600 "${ENV_FILE}"
  log ".env 生成完毕（权限 600）"
fi

# shellcheck disable=SC1090
set -a; . "${ENV_FILE}"; set +a

# ================================================================ 2. 数据库配置
mysql_root() {
  if [[ -n "${GRADDU_MYSQL_ROOT_PASSWORD:-}" ]]; then
    mysql -uroot -p"${GRADDU_MYSQL_ROOT_PASSWORD}" "$@"
  else
    mysql -uroot "$@"
  fi
}

log "检测本机 MySQL 连接..."
if ! mysql_root -e "SELECT 1;" >/dev/null 2>&1; then
  die "无法以 root 连接本机 MySQL，请确认 MySQL 服务已启动"
fi
log "MySQL 连接正常"

log "创建数据库 ${DB_NAME} 与用户 ${DB_APP_USER} ..."
mysql_root -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql_root -e "CREATE USER IF NOT EXISTS '${DB_APP_USER}'@'127.0.0.1' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql_root -e "CREATE USER IF NOT EXISTS '${DB_APP_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql_root -e "ALTER USER '${DB_APP_USER}'@'127.0.0.1' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql_root -e "ALTER USER '${DB_APP_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql_root -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_APP_USER}'@'127.0.0.1';"
mysql_root -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_APP_USER}'@'localhost';"
mysql_root -e "FLUSH PRIVILEGES;"

log "✅ 数据库 ${DB_NAME} 及账号 ${DB_APP_USER} 配置完毕"
log "✅ Graddu 官网基础设施初始化完成"
