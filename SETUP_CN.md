# 🕵️ DarkWeb Forums Tracker - 保姆级部署指南

本指南将带你一步步部署这套暗网威胁情报监控系统，从环境配置到最终接收 Discord 警报。

## 📋 准备工作

在开始之前，请确保你已经准备好了以下环境和账号：

- **Docker** (v20.10+) 和 **Docker Compose** (v2.0+)：系统的运行基础。
- **Git**：用于下载代码。
- **Supabase Cloud 账号**：[注册免费账号](https://supabase.com)，用于数据库和截图存储。
- **Google Gemini API Key**：[免费申请](https://aistudio.google.com/)，用于驱动 AI 智能分析。
- **Discord Webhook**：用于接收报警通知。

---

## 🚀 快速部署流程

### 第一步：克隆代码与环境配置

```bash
# 1. 下载项目代码
git clone https://github.com/brunosergi/darkweb-forums-tracker.git
cd darkweb-forums-tracker

# 2. 复制配置文件
cp .env.example .env
```

### 第二步：配置 Supabase 云端后台

我们需要 Supabase 来存储监控到的帖子数据和截图证据。

1. **创建项目**：登录 [supabase.com](https://supabase.com) 创建一个新项目。
2. **获取 API 凭证**：
   - 进入 **Settings (设置)** -> **API**。
   - 复制 **Project URL** (项目地址)。
   - 复制 **service_role** secret (注意：**不是** anon key，我们需要 service_role 权限来绕过部分限制进行后端操作)。
3. **初始化数据库**：
   - 进入左侧菜单的 **SQL Editor**。
   - 打开项目中的 `supabase/supabase.sql` 文件，复制全部内容。
   - 在 Supabase 的 SQL Editor 中粘贴并点击 **Run** 执行，建表成功后你会看到 `Success` 提示。
4. **配置截图存储**：
   - 进入左侧菜单的 **Storage**。
   - 点击 **New Bucket** 创建一个新桶。
   - **Name (名称)** 填入：`screenshots`。
   - **Public (公开)**：**必须开启** (Discord 需要公开链接才能展示图片预览)。
   - (可选) Save 后，可以在 Configuration 中设置上传限制（如 500KB）和文件类型（image/jpeg）。

### 第三步：填入关键配置

使用文本编辑器打开本地的 `.env` 文件，填入刚才获取的信息：

```bash
# Supabase 配置
SUPABASE_URL=https://your-project.supabase.co
# 【重要】这里填入 service_role key，而不是 anon key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# N8N 安全配置 (生成一个随机字符串即可)
N8N_ENCRYPTION_KEY=super-secure-random-string-at-least-32-chars

# 数据库密码 (N8N 内部使用的 Postgres，随便设置一个复杂的密码)
POSTGRES_PASSWORD=my-secret-db-password
POSTGRES_DB=postgres
```

### 第四步：一键启动

```bash
docker compose up -d
```

> **提示**：首次启动时，系统会构建包含中文插件的 N8N 镜像，可能需要几分钟时间，请耐心等待。
> 启动完成后，你可以使用 `docker compose ps` 查看服务状态，所有服务都应显示 `healthy` 或 `running`。

---

## 🔧 N8N 初始化配置

服务启动后，我们需要进行一次性的配置来连接各个组件。

### 1. 登录 N8N
访问浏览器：**http://localhost:5678**
首次访问需要设置管理员账户，请按提示创建。

### 2. 配置凭证 (Credentials)
这是最关键的一步。我们需要在 N8N 中添加外部服务的连接凭证。
点击左侧菜单的 **Credentials (凭证)** -> **Add Credential**。

#### a. 添加 Supabase 凭证
- **类型**：搜索并选择 `Supabase API`
- **Name**: `Supabase account` (建议保持此默认名称，方便对应)
- **Host**: 填入你的 Supabase Project URL (如 `https://xxx.supabase.co`)
- **Service Role Key**: 填入你的 `service_role` key
- 点击 **Save**。

#### b. 添加 Google Gemini 凭证
- **类型**：搜索 `Google Gemini(PaLM) API`
- **Name**: `Google Gemini(PaLM) Api account`
- **API Key**: 填入你的 Gemini API Key
- 点击 **Save**。

#### c. 添加 Discord Webhook 凭证
1. **获取 Webhook URL**：
   - 在 Discord 频道设置 -> Integrations -> Webhooks -> New Webhook。
   - 复制生成的 Webhook URL。
2. **在 N8N 中添加**：
   - **类型**：搜索 `Discord Webhook`
   - **Name**: `Discord Darkforums Chat`
   - **Webhook URL**: 粘贴刚才复制的 URL。
   - 点击 **Save**。

### 3. 检查与激活工作流

1. 点击左侧 **Workflows**。
2. 你应该能看到两个已导入的工作流：
   - `darkweb-get-forum-posts` (负责监控和抓取)
   - `darkweb-send-forum-posts-to-discord` (负责分析和推送)
3. **重要**：如果工作流节点因为我们之前的重命名显示警告，请双击打开工作流，检查那些带有红色感叹号的节点，确保它们的 `Credential` 字段选中了我们刚才创建的凭证。
4. 将两个工作流右上角的 **Active** 开关打开（变为绿色）。

---

## 🖥️ VNC 远程交互 (不仅是看，还能动！)

本系统不仅仅是后台爬虫，它还提供了一个可视化的浏览器界面。

**访问地址**：http://localhost:6080

### 这个界面有什么用？
- **看直播**：你可以实时看到 AI 正在浏览器里做什么。
- **帮把手**：
    - 如果 AI 卡在 **Cloudflare 验证** 页面，你可以进去点一下。
    - 如果论坛需要 **登录** 才能看帖子，你可以手动输一次账号密码（选中 "Remember me"），Playwright 容器会把 Cookie 保存下来，下次 AI 就能自动以登录状态访问了。

### 如何操作
这就像是一个网页版的远程桌面。
- 如果进去是黑屏但有终端窗口，说明浏览器还没启动。
- 若要手动启动浏览器调试：
    - 右键桌面 -> Applications -> Shells -> Bash
    - 输入命令：`chromium &`

---

## 🔄 进阶：如何监控其他论坛？

目前的默认配置是针对 `DarkForums.io` 的。如果你想监控其他类似论坛：

1. 打开 `darkweb-get-forum-posts` 工作流。
2. 找到首部的 **Code** 节点（通常命名为 `xxx Metadata`）。
3. 修改 JSON 配置中的 `forum_urls_to_track` 数组，填入你想监控的板块 URL。
4. (高阶) 如果目标论坛结构差异很大，你需要调整 **AI Agent** 节点的 `System Message` (提示词)，告诉 AI 如何在该特定论坛上定位标题、作者和时间。

---

## ❓ 常见问题排查

**Q: 为什么 N8N 里节点名称是中文的？**
A: 为了方便使用，我们已经将工作流汉化。如果你如果不喜欢，可以切回英文版 Docker 镜像（修改 docker-compose.yml），但建议保留中文以便理解。

**Q: 截图上传失败？**
A: 请检查 Supabase 的 Storage Bucket 设置，确保 `screenshots` 桶是 **Public** 的，且你的 `service_role` key 配置正确。

**Q: AI 报错 `bot_captcha`？**
A: 这说明遇到了很难缠的反爬盾。请立刻访问 VNC (http://localhost:6080)，手动帮 AI 过一下验证，通常过一次后 Session 会保持一段时间。

**Q: 数据库里没数据？**
A: 检查 Supabase 的 Database 面板。如果表是空的，可能是 `supabase.sql` 脚本没跑成功，或者是 N8N 连接 Supabase 失败（检查凭证）。

---

**祝你狩猎愉快！Happy Hunting!** 🛡️