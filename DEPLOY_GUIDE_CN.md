# ☁️ 云平台部署指南 (Zeabur / ClawCloud)

## ⚠️ 核心警告：资源消耗 (请务必阅读)
本项目包含 **Chromium 浏览器 (Playwright)** 和 **PostgreSQL 数据库**，属于**重资源应用**。
*   **Zeabur 免费额度 ($5/月)**: 仅能支撑短期(几天)测试或间歇性运行。**24小时运行必超额/OOM**。
*   **建议**: 如果您决定长期使用，建议使用 **ClawCloud** 或其他 VPS。

---

## 🟢 选项 A: 部署到 Zeabur (微服务拆分模式 - 最稳妥)

您刚才遇到的“只显示一个服务”是因为 Zeabur 对复杂 `docker-compose` 的解析有时不完美。
**最佳方案**是利用 Zeabur 的优势，**分别创建 4 个服务**，这样您可以单独控制每个服务的资源和环境变量。

### 第一步：创建项目
1.  登录 Zeabur，点击 **Create Project**，选择节点 (建议 SG/JP)。

### 第二步：创建数据库 (使用 Marketplace)
1.  **PostgreSQL**:
    *   点击 **Create Service** -> **Marketplace** -> 搜索 **PostgreSQL** -> 部署。
    *   部署后，在服务卡片里找到 Connection 信息（Host, Port, User, Password），记下来备用。
2.  **Redis**:
    *   点击 **Create Service** -> **Marketplace** -> 搜索 **Redis** -> 部署。
    *   同样记下连接信息。

### 第三步：部署 N8N (Git 服务)
1.  点击 **Create Service** -> **Git** -> 选择您的 `darkweb-forums-tracking` 仓库。
2.  部署后会失败（或者状态不对），不要慌，点击该服务进入 **Settings**：
    *   **Root Directory (根目录)**: 输入 `n8n` 并保存。
    *   **Watch Paths**: 输入 `n8n` (可选)。
3.  进入 **Variables**，填入以下变量 (参考 `ZEABUR_ENV.txt`):
    *   `DB_TYPE`: `postgresdb`
    *   `DB_POSTGRESDB_HOST`: 填入刚才 PostgreSQL 服务的 Host (通常是 `postgresql`)
    *   `DB_POSTGRESDB_PORT`: `5432`
    *   `DB_POSTGRESDB_PASSWORD`: 填入 PostgreSQL 的密码
    *   `QUEUE_BULL_REDIS_HOST`: 填入 Redis 服务的 Host (通常是 `redis`)
    *   `N8N_ENCRYPTION_KEY`: 自定义密钥
    *   `SUPABASE_URL`: 您的 Supabase 地址
    *   `PORT`: `5678` (Zeabur 会自动识别并暴露此端口)
    *   `N8N_BLOCK_ENV_ACCESS_IN_NODE`: `false` (允许 N8N 读取环境变量，解决 [ERROR: access to env vars denied])
4.  这步完成后，N8N 应该就能启动成功了。记得在 Networking 里绑定一个域名。

### 第四步：部署 Playwright MCP (Git 服务)
1.  再次点击 **Create Service** -> **Git** -> 选择同一个 `darkweb-forums-tracking` 仓库。
2.  进入 **Settings**：
    *   **Root Directory**: 输入 `playwright-mcp` 并保存。
3.  进入 **Variables**：
    *   `PLAYWRIGHT_MCP_PORT`: `8831`
    *   **PORT**: `8831` (告诉 Zeabur 暴露这个端口)
4.  在 Networking 里绑定域名（用于 VNC 访问）。

### 第五步：配置 AI 凭证 (OpenAI)
1.  进入 N8N 界面，点击右上角 **Credentials**。
2.  新建 **OpenAI API** 凭证，填入您的 Key (`sk-...`)。
3.  打开导入的工作流，检查那两个 AI 节点 (GPT-4o) 是否选中了这个凭证。

---

## 🔵 选项 B: 部署到 ClawCloud (VPS 模式 - 推荐)
如果您购买了 ClawCloud 的 VPS，操作就和我们在本地一样简单，而且性能更强。

1.  SSH 登录 VPS。
2.  拉取代码:
    ```bash
    git clone https://github.com/<您的用户名>/darkweb-forums-tracking.git
    cd darkweb-forums-tracking
    ```
3.  配置环境:
    ```bash
    cp .env.example .env
    vi .env  # 填入您的密钥
    ```
4.  启动:
    ```bash
    docker compose up -d
    ```

---
**总结**: Zeabur 拆分部署虽然步骤多一点，但能保证每个模块（数据库、N8N、Playwright）都独立运行，互不干扰，排查问题也最方便。

## ❓ 常见问题 (Troubleshooting)

### Q: 报错 "Browser specified in your config is not installed"
**原因**: Docker 镜像里的浏览器版本和代码库里的 Playwright 版本不匹配。
**解决**: 我们已经更新了 Dockerfile 修复此问题。
**重要操作**: 请在 Zeabur 的 Playwright 服务页面，点击 **Redeploy (重新部署)**。
> ⚠️ **注意**: 不要点 Restart (重启)，重启不会重新构建 Docker 镜像，必须点 **Redeploy** 才会应用我们刚才的修复。
