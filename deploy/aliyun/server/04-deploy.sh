#!/usr/bin/env bash
# ============================================================================
# Graddu 部署脚本 —— 切换 releases/latest 产物上线 (systemd + Nginx)
# 目标域名：www.graddu.com / graddu.com
# ============================================================================
set -euo pipefail

GRADDU_ROOT="${GRADDU_ROOT:-/opt/graddu}"
RELEASE_DIR="${GRADDU_ROOT}/releases/latest"
APP_DIR="${GRADDU_ROOT}/app"
WWW_DIR="${GRADDU_ROOT}/www"
BACKUP_DIR="${GRADDU_ROOT}/backups"
SERVICE_NAME="graddu-backend"
HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-120}"
DO_HEALTHCHECK="yes"
KEEP_SOURCE="no"

log()  { printf '\033[0;32m[deploy]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[deploy]\033[0m %s\n' "$*"; }
die()  { printf '\033[0;31m[deploy][ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

for arg in "$@"; do
  case "${arg}" in
    --clean-source)
      log "安全清理：彻底清除服务器源码目录 (${GRADDU_ROOT}/src)..."
      rm -rf "${GRADDU_ROOT}/src"
      rm -f /tmp/graddu-src*.tar.gz /tmp/graddu-*.tar.gz
      log "✅ 服务器源码已彻底清除"
      exit 0
      ;;
    --no-healthcheck) DO_HEALTHCHECK="no" ;;
    --keep-source)    KEEP_SOURCE="yes" ;;
  esac
done

[[ $EUID -eq 0 ]] || die "请用 root 执行（sudo bash $0）"
[[ -d "${RELEASE_DIR}" ]] || die "没有可部署的版本: ${RELEASE_DIR}（先执行 03-build.sh）"
[[ -f "${RELEASE_DIR}/app.jar" ]] || die "版本目录缺少 app.jar: ${RELEASE_DIR}"

if [[ -f "${GRADDU_ROOT}/.env" ]]; then set -a; . "${GRADDU_ROOT}/.env"; set +a; fi

mkdir -p "${APP_DIR}" "${WWW_DIR}" "${BACKUP_DIR}" "${GRADDU_ROOT}/logs" "${GRADDU_ROOT}/data/uploads"
if [[ ! -f "${GRADDU_ROOT}/data/downloads.json" ]]; then
  echo "[]" > "${GRADDU_ROOT}/data/downloads.json"
fi
chmod 755 "${GRADDU_ROOT}/data"

# ---------------- 1. 备份当前 jar ----------------
if [[ -f "${APP_DIR}/app.jar" ]]; then
  BK="${BACKUP_DIR}/app.jar.$(date +%Y%m%d-%H%M%S).bak"
  cp "${APP_DIR}/app.jar" "${BK}"
  log "已备份当前后端产物 -> ${BK}"
fi

# ---------------- 2. 切换后端 ----------------
log "部署后端应用 -> ${APP_DIR}/app.jar"
install -m 644 "${RELEASE_DIR}/app.jar" "${APP_DIR}/app.jar"

# 确保 app 目录下能直接访问 data 目录
ln -sfn "${GRADDU_ROOT}/data" "${APP_DIR}/data"

# ---------------- 3. 切换前端 ----------------
if [[ -d "${RELEASE_DIR}/www" ]]; then
  log "部署前端静态站点 -> ${WWW_DIR}"
  rm -rf "${WWW_DIR:?}"/* && cp -r "${RELEASE_DIR}/www/." "${WWW_DIR}/"
fi

# ---------------- 4. 配置 systemd 服务 ----------------
JAVA_BIN="$(readlink -f "$(command -v java)")"
log "配置 systemd 服务: /etc/systemd/system/${SERVICE_NAME}.service"
cat > "/etc/systemd/system/${SERVICE_NAME}.service" <<UNIT
[Unit]
Description=Graddu Official Website Backend (Spring Boot)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=${APP_DIR}
EnvironmentFile=${GRADDU_ROOT}/.env
ExecStart=${JAVA_BIN} \$JAVA_OPTS -jar ${APP_DIR}/app.jar
ExecStop=/bin/kill -TERM \$MAINPID
SuccessExitStatus=143
Restart=always
RestartSec=10
TimeoutStopSec=30
StandardOutput=append:${GRADDU_ROOT}/logs/backend.log
StandardError=append:${GRADDU_ROOT}/logs/backend.log
PrivateTmp=true

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}" >/dev/null 2>&1

# ---------------- 5. 配置 Nginx 站点 ----------------
SERVER_NAME="${GRADDU_SERVER_NAME:-www.graddu.com}"
EXTRA_DOMAINS="${GRADDU_EXTRA_DOMAINS:-graddu.com}"
CERT_DIR="/etc/letsencrypt/live/${SERVER_NAME}"
mkdir -p /var/www/certbot/.well-known/acme-challenge

# 兼容 Debian/Ubuntu (sites-available) 与 CentOS/RHEL/Alibaba Cloud Linux (conf.d)
USE_SITES_DIR="no"
if [[ -d /etc/nginx/sites-available && -d /etc/nginx/sites-enabled ]]; then
  USE_SITES_DIR="yes"
  NGINX_TARGET="/etc/nginx/sites-available/graddu"
  NGINX_LINK="/etc/nginx/sites-enabled/graddu"
else
  NGINX_TARGET="/etc/nginx/conf.d/graddu.conf"
  NGINX_LINK=""
fi

render_site() {
  sed -e "s#__GRADDU_ROOT__#${GRADDU_ROOT}#g" \
      -e "s#__SERVER_NAME__#${SERVER_NAME}#g" \
      -e "s#__BACKEND_PORT__#${SERVER_PORT:-8082}#g" \
      -e "s#__SSL_CERT__#${CERT_DIR}/fullchain.pem#g" \
      -e "s#__SSL_KEY__#${CERT_DIR}/privkey.pem#g" \
      "$1" > "$2"
}

safe_nginx_switch() {
  local newconf="$1"
  cp "${newconf}" "${NGINX_TARGET}"
  if [[ "${USE_SITES_DIR}" == "yes" && -n "${NGINX_LINK}" ]]; then
    ln -sfn "${NGINX_TARGET}" "${NGINX_LINK}"
  fi

  if ! nginx -t 2>/tmp/nginx-t.err; then
    warn "Nginx 配置检测失败，错误信息："
    sed 's/^/    /' /tmp/nginx-t.err
    if [[ "${USE_SITES_DIR}" == "yes" && -n "${NGINX_LINK}" ]]; then
      rm -f "${NGINX_LINK}"
    fi
    return 1
  fi

  systemctl reload nginx
  return 0
}

# 检查证书是否存在
HAVE_CERT="no"
if [[ -f "${CERT_DIR}/fullchain.pem" && -f "${CERT_DIR}/privkey.pem" ]]; then
  log "发现已有 SSL 证书: ${CERT_DIR}"
  HAVE_CERT="yes"
else
  log "未检测到现有证书，先使用 HTTP 引导配置上线..."
  render_site "${GRADDU_ROOT}/scripts/nginx-graddu-bootstrap.conf" /tmp/graddu-nginx-bootstrap.conf
  safe_nginx_switch /tmp/graddu-nginx-bootstrap.conf

  log "尝试申请 Let's Encrypt 证书 (域名: ${SERVER_NAME} ${EXTRA_DOMAINS})..."
  CERTBOT_DOMAINS=(-d "${SERVER_NAME}")
  if [[ -n "${EXTRA_DOMAINS}" ]]; then
    for ed in ${EXTRA_DOMAINS}; do CERTBOT_DOMAINS+=(-d "${ed}"); done
  fi

  if certbot certonly --webroot -w /var/www/certbot \
       "${CERTBOT_DOMAINS[@]}" --non-interactive --agree-tos \
       --email "${CERTBOT_EMAIL:-hjp9221@63.com}" --keep-until-expiring 2>&1 | tail -20; then
    if [[ -f "${CERT_DIR}/fullchain.pem" ]]; then
      log "✅ SSL 证书签发成功"
      HAVE_CERT="yes"
    fi
  else
    warn "Let's Encrypt 证书签发未完成（如公网 DNS 尚未解析到本服务器），先以 HTTP 模式运行。"
    warn "待 DNS 解析生效后，可随时运行: certbot certonly --webroot -w /var/www/certbot -d ${SERVER_NAME} -d ${EXTRA_DOMAINS}"
  fi
fi

if [[ "${HAVE_CERT}" == "yes" ]]; then
  log "启用 HTTPS 正式站点配置..."
  render_site "${GRADDU_ROOT}/scripts/nginx-graddu.conf" /tmp/graddu-nginx.conf
else
  log "启用 HTTP 站点配置..."
  render_site "${GRADDU_ROOT}/scripts/nginx-graddu-bootstrap.conf" /tmp/graddu-nginx.conf
fi

safe_nginx_switch /tmp/graddu-nginx.conf
rm -f /tmp/graddu-nginx.conf /tmp/graddu-nginx-bootstrap.conf 2>/dev/null || true

# ---------------- 6. 启动后端应用 ----------------
log "重启后端服务 ${SERVICE_NAME} ..."
systemctl restart "${SERVICE_NAME}"

# ---------------- 7. 健康检查 ----------------
if [[ "${DO_HEALTHCHECK}" == "yes" ]]; then
  log "执行后端健康检查（最多等待 ${HEALTH_TIMEOUT} 秒）..."
  BACKEND_OK="no"
  for i in $(seq 1 "$((HEALTH_TIMEOUT / 3))"); do
    if curl -fsS --max-time 3 "http://127.0.0.1:${SERVER_PORT:-8082}/api/news" 2>/dev/null | grep -q 'title'; then
      BACKEND_OK="yes"
      log "后端响应正常 (耗时约 $((i*3)) 秒)"
      break
    fi
    if ! systemctl is-active --quiet "${SERVICE_NAME}"; then
      warn "后端进程已退出，最近日志："
      tail -n 40 "${GRADDU_ROOT}/logs/backend.log" 2>/dev/null || true
      die "后端服务启动失败"
    fi
    sleep 3
  done

  [[ "${BACKEND_OK}" == "yes" ]] || {
    warn "健康检查超时，最近日志："
    tail -n 40 "${GRADDU_ROOT}/logs/backend.log" 2>/dev/null || true
    die "后端健康检查超时"
  }
fi

# ---------------- 8. 源码清理 ----------------
if [[ "${KEEP_SOURCE}" != "yes" ]]; then
  log "部署验证通过，清除服务器源码目录 (${GRADDU_ROOT}/src)..."
  rm -rf "${GRADDU_ROOT}/src"
  rm -f /tmp/graddu-src*.tar.gz /tmp/graddu-*.tar.gz
  log "✅ 源码已安全清理"
fi

PROTO="http"
if [[ "${HAVE_CERT}" == "yes" ]]; then PROTO="https"; fi

cat <<EOF

$(printf '\033[0;32m[deploy]\033[0m') Graddu 官网部署成功上线！
  官方主页: ${PROTO}://${SERVER_NAME}/ (及 ${PROTO}://${EXTRA_DOMAINS}/)
  管理后台: ${PROTO}://${SERVER_NAME}/console/login
  API 接口: ${PROTO}://${SERVER_NAME}/api/news
  服务状态: $(systemctl is-active ${SERVICE_NAME})
  日志路径: ${GRADDU_ROOT}/logs/backend.log
EOF
