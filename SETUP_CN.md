# 🕵️ DarkWeb Forums Tracker - 完整设置指南

从git克隆到使用Discord警报监控暗网论坛的完整部署指南。

## 前置条件

- **Docker** (v20.10+) 和 **Docker Compose** (v2.0+)
- **Git** 用于克隆仓库
- **Supabase Cloud账户** (免费套餐可用)
- **Google Gemini API密钥** (可从 [Google AI Studio](https://aistudio.google.com/) 免费获取)
- **Discord webhook URL** 用于接收通知

---

## 🎯 快速部署

### 1. 克隆并配置

```bash
git clone https://github.com/brunosergi/darkweb-forums-tracker.git
cd darkweb-forums-tracker
cp .env.example .env
```

### 2. Supabase Cloud设置

1. **创建项目**: 访问 [supabase.com](https://supabase.com) 并创建新项目
2. **获取项目URL**: 从设置 → API 复制您的项目URL
3. **获取服务角色密钥**: 从设置 → API 复制您的服务角色密钥
4. **运行数据库脚本**: 
   - 进入Supabase仪表板中的SQL编辑器
   - 复制并运行 `supabase/supabase.sql` 中的完整脚本
5. **创建截图存储桶**:
   - 进入Supabase仪表板中的存储
   - 创建名为 `screenshots` 的新存储桶
   - 将其设置为 **公开** (Discord嵌入需要)
   - 可选: 设置500KB上传限制并限制为 `image/jpeg`

### 3. 编辑环境变量

打开 `.env` 并配置以下必要变量:

```bash
# Supabase Cloud配置
SUPABASE_URL=https://your-project.supabase.co

# N8N配置（生成强随机字符串）
N8N_ENCRYPTION_KEY=your-super-secret-key-here-32-chars-min

# 数据库配置
POSTGRES_PASSWORD=your-super-secret-and-long-postgres-password
POSTGRES_DB=postgres
```

### 4. 启动平台

```bash
docker compose up -d
```

这将自动:
- 为N8N设置PostgreSQL数据库
- 配置Redis用于N8N队列管理
- 启动带有VNC支持和共享浏览器会话的Playwright MCP
- 导入带有增强AI代理和重试逻辑的N8N工作流
- 使用健康检查启动所有服务

### 5. 验证服务运行状态

```bash
docker compose ps
```

所有服务应显示 "healthy" 状态。

---

## 🔧 N8N配置

### 访问N8N编辑器

1. 打开 **http://localhost:5678**
2. 创建您的管理员账户（首次设置）
3. 配置凭证（这是唯一需要手动操作的步骤）

### 添加Supabase凭证

**设置** → **凭证** → **添加新凭证**

**Supabase API凭证**:
- **名称**: `Supabase Cloud`
- **URL**: 您的Supabase项目URL (例如: `https://your-project.supabase.co`)
- **服务角色密钥**: 使用Supabase项目设置中的 `SUPABASE_SERVICE_ROLE_KEY`

### 添加Google Gemini凭证

**添加Google Gemini API凭证**:
- **名称**: `Gemini API`
- **API密钥**: 从 [Google AI Studio](https://aistudio.google.com/) 获取的API密钥

### 添加Discord Webhook凭证

**创建Discord Webhook**:
1. **选择Discord频道**: 进入您想要接收论坛通知的Discord频道
2. **编辑频道设置**: 右键点击频道 → **编辑频道**
3. **访问集成**: 进入 **集成** 标签页
4. **创建新Webhook**: 点击 **创建Webhook** (或 **查看Webhooks** → **新建Webhook**)
5. **配置机器人**:
   - **名称**: `DarkWeb Forums Tracker` (或您喜欢的名称)
   - **频道**: 选择通知的目标频道
   - **头像**: 可选 - 上传自定义机器人logo
6. **复制Webhook URL**: 点击 **复制Webhook URL**

**在N8N中添加Discord Webhook凭证**:
- **名称**: `Discord Webhook`
- **Webhook URL**: 粘贴您复制的Discord Webhook URL
- **测试**: 发送测试消息以验证Webhook是否正常工作

### 更新工作流凭证

**重要提示**: 即使节点没有显示错误，也请手动验证以下工作流中的凭证:

**darkweb-get-forum-posts**:
- "AI Agent" → "Google Gemini Chat Model" 节点
- "Supabase RPC Check Existing URLs" → "Supabase RPC" HTTP请求节点
- "Add Posts to Supabase" → Supabase节点
- 所有Discord节点
- "Keywords" → 使用规范名称和变体配置实体字典

<div>

<img src="images/workflow_get_forum_posts.png" alt="工作流：获取论坛帖子" width="500">

</div>

**darkweb-send-forum-posts-to-discord**:
- "AI Agent" → "Google Gemini Chat Model" 节点
- "Add Screenshot File to Supabase Bucket" → "Supabase RPC" HTTP请求节点
- "Update Alert Post" → Supabase更新节点
- "Update as Alert Post Error" → Supabase更新节点
- "Update Sent Status" → Supabase更新节点
- 所有Discord节点

<div>

<img src="images/workflow_send_forum_posts_to_discord.png" alt="工作流：发送论坛帖子到Discord" width="500">

</div>

### 激活工作流

1. 进入N8N中的 **工作流**
2. 点击以下两个工作流的 **激活** 开关:
   - `darkweb-get-forum-posts` (带有重试逻辑和实体检测的主要监控工作流)
   - `darkweb-send-forum-posts-to-discord` (Discord通知 + 带有增强日志的警报帖子AI代理工作流)

---

## 🖥️ VNC配置（人工干预）

### 访问VNC界面

**Web浏览器（推荐）**: http://localhost:6080
- 无需安装软件
- 适用于任何现代浏览器
- 点击 "Connect" 访问桌面

**VNC客户端**: `localhost:5900`
- 使用TightVNC、RealVNC或任何VNC查看器
- 无需密码（开发模式）

### 何时使用VNC

- **CAPTCHA解决**: 当AI代理在DDoS-Guard或论坛CAPTCHA上卡住时
- **手动登录**: 首次登录受保护的论坛
- **会话恢复**: 当登录会话过期时重新认证
- **机器人检测**: 绕过需要人工交互的反机器人措施

VNC界面运行完整的Chrome浏览器，您可以看到AI代理看到的内容，并与任何需要人工输入的元素进行交互。

### 手动浏览器控制

当您需要手动启动Chromium进行故障排除、认证或CAPTCHA解决时:

**VNC Web界面**:
- 按下 **Alt+F2** 并输入: `chromium`
- 或右键点击桌面 → 应用程序 → 运行终端并输入: `chromium &`

**容器终端**:
```bash
docker exec -it darkweb-forums-tracker-playwright bash
chromium &
```

这非常适合解决CAPTCHA、设置认证cookie、调试失败的抓取或手动导航AI代理无法自动处理的复杂登录流程。

<div align="center">

<img src="images/vnc_browser_interaction.png" alt="VNC浏览器界面 - AI代理论坛访问" width="500">

</div>

<div align="center">

<img src="images/vnc_manual_captcha.png" alt="VNC手动解决CAPTCHA" width="350" style="margin-right: 10px;">
<img src="images/vnc_manual_login.png" alt="VNC手动登录" width="350">

</div>

---

## 🎉 开始监控论坛

### 验证一切正常工作

1. **检查N8N**: http://localhost:5678 - 两个工作流都应处于活动状态
2. **测试VNC**: http://localhost:6080 - 应显示带有浏览器的桌面
3. **检查Discord**: 验证Webhook URL是否正常工作
4. **数据库**: 确认Supabase中存在 `darkweb_forums` 表

### 监控执行情况

**系统每4小时自动运行一次，但您可以**:
- **手动触发**: 在N8N中手动执行工作流进行测试
- **检查日志**: 在N8N中查看执行日志进行调试
- **VNC监控**: 通过VNC实时观察浏览器自动化
- **Discord更新**: 接收扫描开始/完成/失败的通知

### 预期的Discord流程

1. **"Forum tracking started"** - 扫描开始，带有跟踪通知
2. **论坛帖子** - 普通帖子（蓝色）和实体警报（红色，带有截图和AI摘要）
3. **重试通知** - 如果初始尝试失败，显示黄色警报
4. **"Forum tracking completed"** - 扫描完成，带有时间戳和处理统计信息

---

## 🔄 自定义

### 添加更多论坛

**在 `darkweb-get-forum-posts` 工作流中**:
1. 更新 "DarkForums.st Metadata" 节点
2. 向论坛列表添加新的论坛URL
3. 修改AI代理提示以适应论坛特定的解析

### 配置实体检测关键词

**在 `darkweb-get-forum-posts` 工作流中**:
1. 找到 "Keywords" 节点
2. 使用规范名称和变体更新实体字典:
```javascript
[
  ["lockbit"],
  ["facebook", "meta"],
  ["bank of america", "bak"],
  ["united states", "united states of america", " usa ", "american"],
  ["brasil", "brazil", ".br", ".com.br", "brazilian"],
  ["twitter", "x.com", "tweet"]
]
```
**注意**: 每个数组代表一个实体 - 第一个元素是规范名称，其他是变体/别名。

### 更改AI模型

**从Gemini切换到其他模型**:
1. 在N8N中添加新的AI提供商凭证
2. 替换 "Google Gemini Chat Model" 节点
3. 针对不同模型的能力更新提示

---

## 🛠️ 服务URL

| 服务 | URL | 用途 |
|------|-----|------|
| **N8N工作流** | http://localhost:5678 | 自动化管理 |
| **VNC浏览器** | http://localhost:6080 | 人工干预界面 |
| **Supabase控制台** | 您的云项目URL | 数据库管理 |
| **Playwright MCP** | http://localhost:8831 | 浏览器自动化服务 |

---

## 🔧 故障排除

### 常见问题

**N8N凭证错误**:
- 验证所有凭证都已保存在N8N UI中
- 检查Supabase URL和服务角色密钥
- 在N8N凭证设置中测试凭证

**工作流执行失败**:
- 检查Google Gemini API配额/速率限制（重试逻辑将尝试2次）
- 验证Playwright MCP是否可在端口8831访问
- 确保Discord Webhook URL有效
- 在N8N执行日志中监控重试尝试

**VNC连接问题**:
- 确认端口6080可访问
- 检查Docker容器日志: `docker logs darkweb-forums-tracker-playwright`
- 如有需要，重启Playwright容器

**截图上传失败**:
- 确保Supabase `screenshots` 存储桶存在且公开
- 验证服务角色密钥具有存储权限
- 检查存储桶大小限制和文件类型限制

**论坛访问被阻止**:
- 使用VNC手动解决CAPTCHA
- 考虑添加代理支持以进行IP轮换
- 检查论坛是否需要登录/注册

### 数据库问题

**缺少表错误**:
```bash
# 在Supabase SQL编辑器中验证表是否存在于新架构中
SELECT id, post_title, post_date, last_post_date, post_alert, entity_name 
FROM public.darkweb_forums LIMIT 1;

# 如果缺少或架构过时，重新运行supabase/supabase.sql脚本
```

**RLS（行级安全）警告**:
- 更新后的 `supabase/supabase.sql` 脚本包含适当的RLS策略
- 如果看到RLS警告，重新运行脚本

### 重置一切

```bash
# 重置本地容器（保留Supabase云数据）
docker compose down -v --remove-orphans
docker compose up -d

# 如有需要，在N8N中重新导入工作流
# 在N8N UI中重新配置凭证
```

---

## 📊 监控与维护

### 性能监控

- **N8N执行情况**: 监控工作流成功/失败率
- **Supabase使用情况**: 跟踪数据库存储和API调用
- **Discord速率限制**: 确保Webhook调用保持在限制范围内
- **VNC使用情况**: 监控浏览器资源消耗

### 定期维护

- **关键词更新**: 每月审核并更新警报关键词
- **论坛列表**: 添加新的相关论坛
- **凭证轮换**: 定期更新API密钥和密码
- **日志清理**: 归档N8N中的旧执行日志

---

🎉 **准备就绪！** 您的暗网论坛跟踪器现已开始监控论坛并自动发送Discord警报。如需任何手动干预，请使用VNC访问 **http://localhost:6080**。