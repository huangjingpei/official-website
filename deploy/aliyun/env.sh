# ============================================================================
# Graddu 官网阿里云部署配置 —— 针对服务器 121.43.150.109
# 域名: www.graddu.com / graddu.com
# 部署路径: /opt/graddu
# ============================================================================

# ---------------- 服务器连接 ----------------
SERVER_IP="121.43.150.109"
SERVER_USER="root"
SSH_PORT="22"
SSH_KEY="$HOME/.ssh/id_rsa"
REMOTE_ROOT="/opt/graddu"

# ---------------- 访问域名与地址 ----------------
GRADDU_SERVER_NAME="www.graddu.com"
GRADDU_EXTRA_DOMAINS="graddu.com"
GRADDU_PUBLIC_BASE_URL="https://www.graddu.com"

# 证书申请邮箱（Let's Encrypt 到期提醒用）
CERTBOT_EMAIL="hjp9221@63.com"

# 后端监听独立端口 8082（避开 8080/8081），由 Nginx 反向代理
SERVER_PORT="8082"

# ---------------- 数据库（复用服务器已有 MySQL 8.0）----------------
GRADDU_MYSQL_ROOT_PASSWORD=""
DB_NAME="official_website"
DB_USER="official_website"

# ---------------- 管理员初始密码 ----------------
APP_ADMIN_USERNAME="administrator"
APP_ADMIN_PASSWORD="admin123"

# ---------------- JVM 内存上限 ----------------
JAVA_XMX="300m"

# ---------------- 跳过系统包重复安装 ----------------
# 服务器上 JDK17 / Maven / Node20+ / Nginx 已就绪时设为 yes
SKIP_PREPARE="yes"
