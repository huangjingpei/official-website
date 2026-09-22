# 阿里云部署手册（www.graddu.com / graddu.com）

本文档适用于把本官网工程部署到阿里云 ECS 服务器（默认 IP：`121.43.150.109`），并将公网访问域名配置为 **`www.graddu.com`** 与 **`graddu.com`**，服务器部署路径推荐为 **`/opt/graddu`**。

本项目提供两种部署方式：
1. **自动化一键部署（推荐）**：使用 `deploy/aliyun/deploy.sh`，支持一键上传源码、远程编译、配置 MySQL、签发 SSL 证书及服务自检，详见 [deploy/aliyun/README.md](deploy/aliyun/README.md)；
2. **手动分步部署（备用）**：适合深入排查或定制化运维，详见下文。

---

## 1. 部署结构规划

服务器规划路径：
- 基础根路径：`/opt/graddu`
- 后端目录：`/opt/graddu/app`
  - 后端可执行 Jar：`/opt/graddu/app/app.jar`
- 静态网站目录：`/opt/graddu/www`
  - 前端编译静态资源：`/opt/graddu/www/index.html` 及 assets 目录
- 数据与上传文件：
  - 安装包上传存储：`/opt/graddu/data/uploads/`
  - 下载元数据记录：`/opt/graddu/data/downloads.json`
- 日志目录：`/opt/graddu/logs/backend.log`

---

## 2. 服务器准备（ECS）

### 2.1 安全组/防火墙设置
- 放行：`80/tcp`（HTTP 访问及证书验证）、`443/tcp`（HTTPS 安全访问）、`22/tcp`（SSH 登录）
- **严禁对外放行**：`8082/tcp`（后端 Spring Boot 端口只监听 127.0.0.1，由 Nginx 反向代理）、`3306/tcp`（MySQL）

### 2.2 安装运行环境
Alibaba Cloud Linux 3 / CentOS 示例：
```bash
sudo yum -y update
sudo yum -y install git nginx
sudo yum -y install java-17-openjdk java-17-openjdk-devel
```
Ubuntu / Debian 示例：
```bash
sudo apt update
sudo apt -y install git nginx openjdk-17-jdk
```
验证 Java 17：
```bash
java -version
```

---

## 3. MySQL 数据库配置

进入 MySQL 控制台创建数据库与用户：
```sql
CREATE DATABASE IF NOT EXISTS official_website
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'official_website'@'127.0.0.1' IDENTIFIED BY 'YOUR_STRONG_PASSWORD';
CREATE USER IF NOT EXISTS 'official_website'@'localhost' IDENTIFIED BY 'YOUR_STRONG_PASSWORD';

GRANT ALL PRIVILEGES ON official_website.* TO 'official_website'@'127.0.0.1';
GRANT ALL PRIVILEGES ON official_website.* TO 'official_website'@'localhost';
FLUSH PRIVILEGES;
```
> 说明：Spring Boot 后端启动时会自动在 `official_website` 数据库创建 `users` 和 `authorities` 等安全表。

---

## 4. 后端应用构建与运行 (Spring Boot)

### 4.1 构建后端 Jar
在工程根目录下执行：
```bash
./mvnw -DskipTests clean package
```
产物为：`target/official-website-backend-0.0.1-SNAPSHOT.jar`。

### 4.2 部署文件与目录初始化
在服务器上创建目录：
```bash
sudo mkdir -p /opt/graddu/app
sudo mkdir -p /opt/graddu/data/uploads
sudo mkdir -p /opt/graddu/logs
if [ ! -f /opt/graddu/data/downloads.json ]; then
  echo "[]" | sudo tee /opt/graddu/data/downloads.json
fi
```
将打包好的 jar 上传至 `/opt/graddu/app/app.jar`。

### 4.3 配置环境变量与 systemd 服务
创建环境变量配置文件 `/opt/graddu/.env`：
```bash
sudo tee /opt/graddu/.env >/dev/null <<'EOF'
TZ=Asia/Shanghai
SERVER_PORT=8082
SERVER_ADDRESS=127.0.0.1
SPRING_APPLICATION_NAME=official-website-backend

MYSQL_URL=jdbc:mysql://127.0.0.1:3306/official_website?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true&createDatabaseIfNotExist=true
MYSQL_USERNAME=official_website
MYSQL_PASSWORD=YOUR_STRONG_PASSWORD

APP_ADMIN_USERNAME=administrator
APP_ADMIN_PASSWORD=admin123

APP_STORAGE_UPLOAD_DIR=/opt/graddu/data/uploads
APP_STORAGE_METADATA_FILE=/opt/graddu/data/downloads.json

JAVA_OPTS="-Xms128m -Xmx300m -XX:MaxMetaspaceSize=128m -XX:+UseG1GC -Dfile.encoding=UTF-8"
EOF
sudo chmod 600 /opt/graddu/.env
```

创建 systemd 服务 `/etc/systemd/system/graddu-backend.service`：
```bash
sudo tee /etc/systemd/system/graddu-backend.service >/dev/null <<'EOF'
[Unit]
Description=Graddu Official Website Backend (Spring Boot)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/graddu/app
EnvironmentFile=/opt/graddu/.env
ExecStart=/usr/bin/java $JAVA_OPTS -jar /opt/graddu/app/app.jar
Restart=always
RestartSec=5
StandardOutput=append:/opt/graddu/logs/backend.log
StandardError=append:/opt/graddu/logs/backend.log

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now graddu-backend
```

验证后端运行状态：
```bash
curl -I http://127.0.0.1:8082/api/news
```

---

## 5. 前端应用构建与部署 (Vue 3 + Vite)

### 5.1 构建前端产物
在 `official-website-frontend` 目录下执行：
```bash
npm install
npm run build
```
产物位于 `official-website-frontend/dist/`。

### 5.2 部署静态文件
将 `dist/` 内容同步至服务器 `/opt/graddu/www/`：
```bash
sudo mkdir -p /opt/graddu/www
# 将 dist/ 下所有文件复制到 /opt/graddu/www/
```

---

## 6. Nginx 站点配置与反向代理

创建站点配置文件 `/etc/nginx/conf.d/graddu.conf`：
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name www.graddu.com graddu.com;

    # Certbot 验证路径
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        default_type "text/plain";
        try_files $uri =404;
    }

    # 客户端安装包与大文件上传限制 (350MB)
    client_max_body_size 350m;

    # API 接口反向代理至 Spring Boot 后端
    location /api/ {
        client_max_body_size 350m;
        proxy_pass http://127.0.0.1:8082;
        proxy_http_version 1.1;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Range             $http_range;
        proxy_set_header If-Range          $http_if_range;
    }

    # 前端单页面应用托管
    location / {
        root /opt/graddu/www;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
```

测试并重载 Nginx：
```bash
sudo nginx -t && sudo systemctl reload nginx
```

---

## 7. 配置 HTTPS (Let's Encrypt 证书)

运行 Certbot 为 `www.graddu.com` 和 `graddu.com` 同时签发证书：
```bash
sudo certbot --nginx -d www.graddu.com -d graddu.com
```
选择自动重定向（Redirect HTTP to HTTPS）。
申请成功后，访问 `http://graddu.com` 或 `http://www.graddu.com` 会自动跳转为安全的 `https://www.graddu.com`。

---

## 8. 访问地址与初始账号

- **官网前台**：[https://www.graddu.com/](https://www.graddu.com/)
- **管理后台**：[https://www.graddu.com/console/login](https://www.graddu.com/console/login)
- **初始管理员账号**：`administrator`
- **初始管理员密码**：`admin123`（在 `/opt/graddu/.env` 中定义，登录后建议在后台 `/console/password` 修改）
