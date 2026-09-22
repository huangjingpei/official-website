#!/usr/bin/env bash
# ============================================================================
# Graddu 官网编译构建脚本 —— 构建后端 jar 与前端产物
# 产物落入 releases/<时间戳>/ 并软链至 releases/latest
# ============================================================================
set -euo pipefail

GRADDU_ROOT="${GRADDU_ROOT:-/opt/graddu}"
SRC_DIR="${GRADDU_ROOT}/src"

log()  { printf '\033[0;32m[build]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[build]\033[0m %s\n' "$*"; }
die()  { printf '\033[0;31m[build][ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "请用 root 执行（sudo bash $0）"
[[ -f "${SRC_DIR}/pom.xml" ]] || die "后端源码缺失: ${SRC_DIR}/pom.xml"

export PATH="/opt/maven/bin:/opt/node/bin:${PATH}"
export CI=true

# 内存上限限制，防止小内存服务器触发系统 OOM
export MAVEN_OPTS="-Xmx512m -Dfile.encoding=UTF-8"
export NODE_OPTIONS="--max-old-space-size=512"

TS="$(date +%Y%m%d-%H%M%S)"
RELEASE_DIR="${GRADDU_ROOT}/releases/${TS}"
mkdir -p "${RELEASE_DIR}"
log "本次发布版本目录: ${RELEASE_DIR}"

# ================================================================ 1. 后端编译
log "编译 Spring Boot 后端 (Java 17)..."
cd "${SRC_DIR}"
MVN_FLAGS=(-B -ntp -DskipTests -Dmaven.test.skip=true)
if [[ -f /root/.m2/settings.xml ]]; then
  MVN_FLAGS+=(-s /root/.m2/settings.xml)
fi

mvn "${MVN_FLAGS[@]}" clean package

JAR_PATH="$(ls -1 "${SRC_DIR}"/target/official-website-backend-*.jar "${SRC_DIR}"/target/*.jar 2>/dev/null | grep -v '\.original$' | head -1 || true)"
[[ -n "${JAR_PATH}" ]] || die "未找到后端产物 jar"
cp "${JAR_PATH}" "${RELEASE_DIR}/app.jar"
log "后端产物已就绪: ${RELEASE_DIR}/app.jar ($(du -h "${RELEASE_DIR}/app.jar" | cut -f1))"

# ================================================================ 2. 前端编译
if [[ -d "${SRC_DIR}/official-website-frontend" ]]; then
  log "编译前端门户与管理后台 (Vue3 + Vite)..."
  cd "${SRC_DIR}/official-website-frontend"
  npm install --no-audit --no-fund --registry=https://registry.npmmirror.com
  npm run build
  mkdir -p "${RELEASE_DIR}/www"
  cp -r dist/. "${RELEASE_DIR}/www/"
  log "前端构建完成: $(find "${RELEASE_DIR}/www" -type f | wc -l) 个静态资源文件"
fi

# ================================================================ 3. 更新软链接
rm -f "${GRADDU_ROOT}/releases/latest"
ln -s "${RELEASE_DIR}" "${GRADDU_ROOT}/releases/latest"
echo "${TS}" > "${RELEASE_DIR}/BUILD_ID"

log "✅ 构建成功完成: ${RELEASE_DIR} (已挂载至 releases/latest)"
