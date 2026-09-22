# 杭州栩文科技有限公司官方网站 (graddu.com)

欢迎访问 **杭州栩文科技有限公司** 官方网站代码仓库。

- **官方网站**：[https://www.graddu.com](https://www.graddu.com) （支持 [https://graddu.com](https://graddu.com)）
- **ICP备案**：[浙ICP备2021037087号-1](https://beian.miit.gov.cn/)
- **版权声明**：© 2024 graddu.com 版权所有 | 本网站为杭州栩文科技有限公司所有

---

## 1. 公司业务与定位
杭州栩文科技有限公司专注于 AI 与音视频融合技术，为企业提供稳定、高效、可落地的技术服务与解决方案：
- **WebRTC 实时互动**：低延迟音视频通信、多人在线协同与互动。
- **远程桌面支持**：高性能跨平台远程控制、Penclaw 运维协同工具。
- **实时弹幕系统**：高并发弹幕分发、直播互动基础设施。
- **AI 实时交互**：智能语音识别、实时问答与多模态交互接入。

---

## 2. 工程结构与技术栈

本工程采用前后端分离架构：
- **前端门户与管理后台**：`official-website-frontend/`
  - 技术栈：Vue 3 + Vite + Vue Router
  - 支持“商务”与“可爱”双主题切换
  - 提供前台展示页面与后台管理控制台（`/console`）
- **后端服务**：根目录下 `src/` 与 `pom.xml`
  - 技术栈：Spring Boot 3.5.0 + Spring Security + Spring JDBC + MySQL + OpenAPI (Swagger)，Java 17
  - 核心功能：新闻动态接口、大文件 HTTP Range 分片断点续传下载、意向留言接收、基于 JDBC 的权限管理与改密
- **部署方案**：`deploy/aliyun/` 与 `DEPLOY_ALIYUN.md`
  - 针对阿里云 ECS（默认路径 `/opt/graddu`），支持一键上传、远程编译、MySQL 初始化、双域名 Let's Encrypt 证书签发与服务自检

---

## 3. 本地快速启动

### 3.1 前端启动
```bash
cd official-website-frontend
npm install
npm run dev
```
访问开发调试地址：`http://localhost:5173`

### 3.2 后端启动
```bash
# 根目录下执行
./mvnw clean spring-boot:run
```
后端服务默认监听：`http://127.0.0.1:8080`（生产环境推荐 8082）

---

## 4. 生产部署指引

详细的部署说明请参见：
- **自动化一键部署手册**：[deploy/aliyun/README.md](deploy/aliyun/README.md)
- **手动逐步部署手册**：[DEPLOY_ALIYUN.md](DEPLOY_ALIYUN.md)
- **系统分析与优化建议报告**：[docs/WEBSITE_ANALYSIS_AND_IMPROVEMENTS.md](docs/WEBSITE_ANALYSIS_AND_IMPROVEMENTS.md)

---

## 5. 资质与版权信息
- **主办单位**：杭州栩文科技有限公司
- **备案编号**：[浙ICP备2021037087号-1](https://beian.miit.gov.cn/)
- **版权所有**：© 2024 graddu.com 版权所有 | 本网站为杭州栩文科技有限公司所有
