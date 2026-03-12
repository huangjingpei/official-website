# 阿里云手动部署文档（ECS + Nginx + MySQL + Spring Boot + Vue）

本文档适用于把本仓库部署到阿里云 ECS 上，采用：

- 前端：Vue（Vite 构建产物为静态文件），由 Nginx 直接托管
- 后端：Spring Boot（Java 17），作为内部服务运行在 `127.0.0.1:8080`
- 数据库：MySQL 8（本机或 RDS 均可）
- Nginx：同域名下反向代理 `/api` 到后端，避免 CORS 与浏览器 Basic 弹窗

---

## 1. 部署结构（推荐）

建议在服务器上按如下路径放置：

- 后端目录：`/opt/official-website/backend`
  - 后端 Jar：`/opt/official-website/backend/app.jar`
  - 上传文件：`/opt/official-website/backend/data/uploads/`
  - 下载元数据：`/opt/official-website/backend/data/downloads.json`
- 前端目录：`/opt/official-website/frontend`
  - 前端静态站点：`/opt/official-website/frontend/dist/`

Nginx 对外只开放 80/443，后端 8080 不对外开放。

---

## 2. 服务器准备（ECS）

### 2.1 安全组/防火墙

- 放行：`80/tcp`、`443/tcp`
- 可选放行：`22/tcp`（SSH）
- 不放行：`8080/tcp`（后端）、`3306/tcp`（MySQL），除非你明确需要远程连接

### 2.2 安装基础软件

以下以 Alibaba Cloud Linux 3 / CentOS 系为例（Ubuntu 可自行换成 `apt`）：

```bash
sudo yum -y update
sudo yum -y install git nginx
sudo yum -y install java-17-openjdk java-17-openjdk-devel
```

验证 Java：

```bash
java -version
```

应显示 17.x。

---

## 3. 安装并初始化 MySQL

你可以二选一：

- 方案 A：ECS 本机 MySQL（本节）
- 方案 B：阿里云 RDS MySQL（跳到 3.3）

### 3.1 安装 MySQL（本机）

不同系统包名可能不一致。若以下命令不可用，请改用你系统仓库中对应的 MySQL 8 包。

```bash
sudo yum -y install mysql-server
sudo systemctl enable --now mysqld
```

### 3.2 创建数据库与账号

进入 MySQL：

```bash
mysql -u root -p
```

执行（请替换强密码）：

```sql
CREATE DATABASE IF NOT EXISTS official_website
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'official_website'@'localhost'
  IDENTIFIED BY 'CHANGE_ME_STRONG_PASSWORD';

GRANT ALL PRIVILEGES ON official_website.* TO 'official_website'@'localhost';
FLUSH PRIVILEGES;
```

> 说明：后端启动时会自动 `CREATE TABLE IF NOT EXISTS users/authorities`（Spring Security 的 JDBC 用户表）。

### 3.3 使用阿里云 RDS（可选）

如果用 RDS，请在安全组/白名单里放行 ECS 出口，并准备好：

- RDS 地址、端口
- 数据库名 `official_website`（建议在 RDS 控制台创建）
- 用户名/密码

后续在环境变量里填 `MYSQL_URL/MYSQL_USERNAME/MYSQL_PASSWORD` 即可。

---

## 4. 构建与部署后端（Spring Boot）

### 4.1 构建 Jar（在本地或服务器都可以）

在代码仓库根目录执行（需要能访问 Maven 仓库）：

```bash
./mvnw -DskipTests clean package
```

构建成功后会生成 `target/*.jar`（名称类似 `official-website-backend-0.0.1-SNAPSHOT.jar`）。

### 4.2 上传 Jar 到服务器

在服务器上准备目录：

```bash
sudo mkdir -p /opt/official-website/backend
sudo mkdir -p /opt/official-website/backend/data/uploads
sudo touch /opt/official-website/backend/data/downloads.json
```

把 jar 上传到：

- `/opt/official-website/backend/app.jar`

（例如使用 scp：`scp target/*.jar root@YOUR_IP:/opt/official-website/backend/app.jar`）

### 4.3 配置后端环境变量

创建环境变量文件：

```bash
sudo tee /etc/official-website-backend.env >/dev/null <<'EOF'
MYSQL_URL=jdbc:mysql://127.0.0.1:3306/official_website?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true&createDatabaseIfNotExist=true
MYSQL_USERNAME=official_website
MYSQL_PASSWORD=CHANGE_ME_STRONG_PASSWORD

APP_ADMIN_USERNAME=administrator
APP_ADMIN_PASSWORD=CHANGE_ME_ADMIN_PASSWORD
EOF
```

> 强烈建议首次登录后台后，到 `/console/password` 修改管理员密码。

### 4.4 创建 systemd 服务

```bash
sudo tee /etc/systemd/system/official-website-backend.service >/dev/null <<'EOF'
[Unit]
Description=Official Website Backend (Spring Boot)
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/official-website/backend
EnvironmentFile=/etc/official-website-backend.env
ExecStart=/usr/bin/java -jar /opt/official-website/backend/app.jar
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

启动并查看状态：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now official-website-backend
sudo systemctl status official-website-backend -l
```

查看日志：

```bash
sudo journalctl -u official-website-backend -f
```

健康检查（在服务器上执行）：

```bash
curl -I http://127.0.0.1:8080/api/news
```

---

## 5. 构建与部署前端（Vue + Vite）

### 5.1 安装 Node.js（建议 18+，推荐 20 LTS）

可使用 nvm 或系统包管理器安装 Node 20。

（示例：如果你使用 nvm，请自行按 nvm 官方文档安装，然后）

```bash
node -v
npm -v
```

### 5.2 构建前端

进入前端目录：

```bash
cd official-website-frontend
npm ci
npm run build
```

产物为：`official-website-frontend/dist/`

### 5.3 部署静态文件

在服务器创建目录：

```bash
sudo mkdir -p /opt/official-website/frontend
```

把 `dist/` 上传到：

- `/opt/official-website/frontend/dist/`

---

## 6. 配置 Nginx（静态托管 + /api 反向代理）

> 注意：本项目上传文件较大，Nginx 需要放大 `client_max_body_size`。

创建站点配置（替换域名 `example.com`）：

```bash
sudo tee /etc/nginx/conf.d/official-website.conf >/dev/null <<'EOF'
server {
  listen 80;
  server_name example.com;

  client_max_body_size 350m;

  root /opt/official-website/frontend/dist;
  index index.html;

  location /api/ {
    proxy_pass http://127.0.0.1:8080;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Connection "";
    proxy_set_header Range $http_range;
    proxy_set_header If-Range $http_if_range;
  }

  location / {
    try_files $uri $uri/ /index.html;
  }
}
EOF
```

检查并重载：

```bash
sudo nginx -t
sudo systemctl enable --now nginx
sudo systemctl reload nginx
```

验证：

```bash
curl -I http://example.com/
curl -I http://example.com/api/news
```

---

## 7. 配置 HTTPS（可选但推荐）

推荐用 Let’s Encrypt（Certbot）或阿里云证书服务。

### 7.1 Certbot（Nginx 自动配置）

适用于 Let’s Encrypt 免费证书，Certbot 可自动生成证书并改写 Nginx（包含 HTTP→HTTPS 跳转）。

#### 7.1.1 前置条件

- 域名 `example.com` 已解析到 ECS 公网 IP（A 记录）
- 安全组已放行 80/443
- Nginx 已安装并能通过 `http://example.com/` 访问（至少能返回 200/301）

#### 7.1.2 安装 Certbot（推荐：Snap）

在 Alibaba Cloud Linux 3 / CentOS 系上推荐用 Snap 安装（版本更新更稳定）：

```bash
sudo yum -y install snapd
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap

sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

如果你的系统是 Ubuntu（可选方案）：

```bash
sudo apt update
sudo apt -y install snapd
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

#### 7.1.3 申请证书并自动改写 Nginx

把 `example.com` 换成你的真实域名（如果有 www，也可以一起加上）：

```bash
sudo certbot --nginx -d example.com
```

过程会让你填写邮箱、同意条款，并选择是否把 HTTP 自动跳转到 HTTPS（建议选 Redirect）。

申请成功后，Certbot 会在 Nginx 站点配置里自动写入 SSL 相关配置并 reload Nginx。

#### 7.1.4 验证与续期

验证 HTTPS：

```bash
curl -I https://example.com/
curl -I https://example.com/api/news
```

测试续期（不会真的续，只做演练）：

```bash
sudo certbot renew --dry-run
```

如果是 Snap 安装，系统通常已自动配置定时任务（可查看）：

```bash
systemctl list-timers | grep -i certbot
```

#### 7.1.5 常见问题

- 申请失败提示 80 端口不可达：检查 DNS 是否生效、阿里云安全组/防火墙是否放行 80、是否有其他程序占用 80
- 站点有多个 server_name：确保 Nginx 配置里 `server_name example.com;` 与你的域名一致，并且 `nginx -t` 通过
- 使用 CDN：建议先在源站完成证书申请与验证，再按 CDN/加速域名策略配置回源与证书

---

## 8. 访问地址与账号

- 官网：`https://example.com/`
- 管理后台登录：`https://example.com/console/login`
- 管理后台首页：`https://example.com/console`
- 修改密码：`https://example.com/console/password`

管理员账号/初始密码来自环境变量：

- `APP_ADMIN_USERNAME`（默认 `administrator`）
- `APP_ADMIN_PASSWORD`（默认 `admin123`，强烈建议在生产修改）

---

## 9. 常见问题排查

### 9.1 后端无法连接 MySQL

- 确认 MySQL 已启动：`systemctl status mysqld`
- 确认账号密码正确（环境变量）
- 确认数据库存在/权限足够（至少需要建表权限）

### 9.2 上传大文件失败

- Nginx：确保 `client_max_body_size 350m;`
- 后端：已配置 `spring.servlet.multipart.max-file-size=300MB`、`max-request-size=350MB`

### 9.3 访问后台出现浏览器弹窗登录框

本项目已配置为 401 返回不触发浏览器 Basic 弹窗；如果你绕过 Nginx 直接访问 8080 或自定义了安全配置，可能会再出现。建议始终通过 Nginx 的 `/api` 访问后端。

---

## 10. 版本更新流程（建议）

### 更新后端

1. 重新构建 jar
2. 上传覆盖 `/opt/official-website/backend/app.jar`
3. 重启服务：`sudo systemctl restart official-website-backend`

### 更新前端

1. 重新 `npm run build`
2. 上传覆盖 `/opt/official-website/frontend/dist/`
3. 重载 Nginx：`sudo systemctl reload nginx`
