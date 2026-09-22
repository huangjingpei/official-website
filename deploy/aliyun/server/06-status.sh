#!/usr/bin/env bash
# ============================================================================
# Graddu 官网服务状态自检脚本
# 用法：sudo bash /opt/graddu/scripts/06-status.sh
# ============================================================================
set -uo pipefail

GRADDU_ROOT="${GRADDU_ROOT:-/opt/graddu}"
SERVICE_NAME="graddu-backend"

C_G='\033[0;32m'; C_Y='\033[0;33m'; C_R='\033[0;31m'; C_C='\033[0;36m'; C_0='\033[0m'
sec() { printf "\n${C_C}===== %s =====${C_0}\n" "$*"; }
ok()  { printf "${C_G}  [OK]${C_0}   %s\n" "$*"; }
bad() { printf "${C_R}  [FAIL]${C_0} %s\n" "$*"; }
warn_(){ printf "${C_Y}  [WARN]${C_0} %s\n" "$*"; }

[[ -f "${GRADDU_ROOT}/.env" ]] && { set -a; . "${GRADDU_ROOT}/.env"; set +a; }
PORT="${SERVER_PORT:-8082}"

sec "Graddu 后端服务状态"
if systemctl is-active --quiet "${SERVICE_NAME}"; then
  ok "${SERVICE_NAME} 运行中 (PID $(systemctl show -p MainPID --value ${SERVICE_NAME}))"
else
  bad "${SERVICE_NAME} 未运行"
fi

sec "健康探测 (本地端口 ${PORT})"
API_RESP="$(curl -fsS --max-time 3 "http://127.0.0.1:${PORT}/api/news" 2>/dev/null || echo '')"
if echo "${API_RESP}" | grep -q 'title'; then
  ok "后端 /api/news 正常响应 JSON 数据"
else
  bad "后端端口 ${PORT} 响应异常或无法连接"
fi

sec "Nginx 域名与反向代理探测"
PROXY_RESP="$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 -H "Host: www.graddu.com" "http://127.0.0.1/api/news" || echo 000)"
if [[ "${PROXY_RESP}" == "200" ]]; then
  ok "Nginx 代理 (www.graddu.com) -> 后端 API (HTTP 200)"
else
  warn_ "Nginx 代理探测返回 HTTP ${PROXY_RESP}"
fi

SITE_RESP="$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 -H "Host: www.graddu.com" "http://127.0.0.1/" || echo 000)"
ok "前端静态门户首页 (www.graddu.com) 响应: HTTP ${SITE_RESP}"

sec "数据库连接探测"
if [[ -n "${MYSQL_PASSWORD:-}" ]] && mysql -u"${MYSQL_USERNAME:-official_website}" -p"${MYSQL_PASSWORD}" -h127.0.0.1 "${DB_NAME:-official_website}" -e "SELECT 1;" >/dev/null 2>&1; then
  ok "MySQL (${DB_NAME:-official_website}) 认证与连接正常"
else
  warn_ "MySQL 未能成功连接，请核对 ${GRADDU_ROOT}/.env 中的数据库账密"
fi
