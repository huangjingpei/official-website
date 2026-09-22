# Graddu 官方门户网站阿里云自动化部署手册

本文档适用于将 **栩文科技官方网站 (graddu)** 自动化部署至阿里云 ECS 服务器（默认 IP：`121.43.150.109`），并将公网访问域名配置为 **`www.graddu.com`** 与 **`graddu.com`**，部署目录为 **`/opt/graddu`**。

---

## 一、 部署架构与拓扑

```
                            阿里云 ECS 121.43.150.109
  ┌────────────────────────────────────────────────────────────────────────┐
  │                                                                        │
  │   客户端访问：                                                         │
  │   - https://www.graddu.com                                             │
  │   - https://graddu.com (301 自动跳转 www.graddu.com)                   │
  │   - http://... (80 端口自动 301 强跳 HTTPS，支持 Let's Encrypt 验证)   │
  │                                                                        │
  │   Nginx (443 / 80)                                                     │
  │      ├── /                 → /opt/graddu/www (Vue 3 静态页面)          │
  │      ├── /api/             → 127.0.0.1:8082 (反向代理 Spring Boot)     │
  │      └── /api/downloads/   → 支持 HTTP Range 大文件分片断点续传 (350M) │
  │                                                                        │
  │   systemd: graddu-backend                                              │
  │      ├── 工作目录: /opt/graddu/app                                     │
  │      ├── 环境变量: /opt/graddu/.env                                    │
  │      ├── 数据存储: /opt/graddu/data/uploads, downloads.json            │
  │      └── MySQL 8.0: 127.0.0.1:3306 (数据库: official_website)          │
  │                                                                        │
  │   ── 与服务器其他运行中服务并存，互不干扰 ──                           │
  └────────────────────────────────────────────────────────────────────────┘
```

### 端口与路径规划
| 组件 | 监听地址/端口 | 路径 | 说明 |
| :--- | :--- | :--- | :--- |
| **Nginx** | `0.0.0.0:80` / `0.0.0.0:443` | `/etc/nginx/conf.d/graddu.conf` | 静态托管 + `/api` 反向代理 + SSL 卸载 |
| **后端应用** | `127.0.0.1:8082` | `/opt/graddu/app/app.jar` | Spring Boot 3.5 (Java 17)，服务名 `graddu-backend` |
| **前端静态** | — | `/opt/graddu/www/` | Vue 3 + Vite 构建产物 |
| **持久数据** | — | `/opt/graddu/data/` | 软件安装包存储及元数据配置 |
| **MySQL** | `127.0.0.1:3306` | 库名 `official_website` | 复用服务器现有 MySQL 实例 |
| **日志目录** | — | `/opt/graddu/logs/` | 后端输出日志与崩溃 Dump |

---

## 二、 前置准备（仅首次需要）

### 2.1 域名解析 (DNS)
登录阿里云云解析 DNS 控制台，添加两条 A 记录指向服务器 IP `121.43.150.109`：
1. 主机记录 `@` -> 对应域名 `graddu.com` -> 解析到 `121.43.150.109`
2. 主机记录 `www` -> 对应域名 `www.graddu.com` -> 解析到 `121.43.150.109`

### 2.2 阿里云安全组开放端口
在阿里云 ECS 控制台 → 安全组规则中确保入方向放行：
- `80/TCP`：用于 HTTP 访问与 Certbot 证书签发验证
- `443/TCP`：用于 HTTPS 安全访问
- `22/TCP`：用于 SSH 部署

> ⚠️ 注意：后端 `8082` 端口只监听 `127.0.0.1`，无需也不应在安全组对外开放！

### 2.3 本地 SSH 免密配置
确保本机终端能够免密连接服务器：
```bash
ssh root@121.43.150.109 "echo 'SSH Connected'"
```

---

## 三、 快速部署指南

在本地代码仓库根目录下，打开 Git Bash 或终端执行：

### 1. 配置部署环境变量
```bash
cd deploy/aliyun
# 检查并编辑 env.sh（默认已针对 graddu.com 与 121.43.150.109 配置就绪）
cat env.sh
```

### 2. 执行一键完整部署
```bash
bash deploy.sh
```
该命令会自动按顺序执行：
1. **测试 SSH 连通性**；
2. **同步远程运维脚本**至 `/opt/graddu/scripts/`；
3. **打包本地源码**（排除本地 node_modules / target / dist）并上传至服务器；
4. **初始化服务器骨架与 MySQL**：自动创建 `/opt/graddu` 目录、新建 `official_website` 数据库与专属账户，生成 `/opt/graddu/.env`；
5. **在服务器远程编译**：使用 Maven 编译后端 Jar，使用 Node/Vite 编译前端静态资源；
6. **上线切换与证书签发**：软链至 `releases/latest`，自动向 Let's Encrypt 申请 `www.graddu.com` 与 `graddu.com` 的 SSL 证书并启用 HTTPS；
7. **启动 systemd 守护进程**并执行健康自检。

---

## 四、 常用运维命令

所有运维操作均可在本地通过 `deploy.sh` 远程触发，也可登录服务器直接执行：

### 4.1 本地运维命令（推荐）
```bash
# 查看服务运行状态、HTTP 状态码及健康自检
bash deploy/aliyun/deploy.sh --status

# 日常代码修改后增量更新（先编译，后发布）
bash deploy/aliyun/deploy.sh --build
bash deploy/aliyun/deploy.sh --deploy-only

# 部署后清理服务器临时源码
bash deploy/aliyun/deploy.sh --clean-source

# 查看可用历史版本并回滚
bash deploy/aliyun/deploy.sh --rollback --list
bash deploy/aliyun/deploy.sh --rollback                # 回滚到上一版本
bash deploy/aliyun/deploy.sh --rollback 20260923-010000 # 回滚到指定版本
```

### 4.2 服务器本地命令
```bash
# 查看后端服务状态
sudo systemctl status graddu-backend

# 查看后端实时日志
tail -f /opt/graddu/logs/backend.log
# 或
sudo journalctl -u graddu-backend -f

# 快速运行自检脚本
sudo bash /opt/graddu/scripts/06-status.sh

# 重载 Nginx 配置
sudo nginx -t && sudo systemctl reload nginx
```

---

## 五、 关键访问入口与默认账密

- **官网主页 (PC / 移动自适应)**：  
  👉 [https://www.graddu.com/](https://www.graddu.com/) （访问 [https://graddu.com/](https://graddu.com/) 会自动规范化重定向至 www）
- **管理后台登录页**：  
  👉 [https://www.graddu.com/console/login](https://www.graddu.com/console/login)
- **下载中心管理后台**：  
  👉 [https://www.graddu.com/console/downloads](https://www.graddu.com/console/downloads)
- **修改后台密码**：  
  👉 [https://www.graddu.com/console/password](https://www.graddu.com/console/password)
- **初始默认管理员账号**：  
  - 账号：`administrator`
  - 初始密码：`admin123`（在 `env.sh` 中配置，首次登录后建议立即在后台修改）
