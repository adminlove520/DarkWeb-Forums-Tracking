# 🕵️ DarkWeb Forums Tracker (暗网论坛追踪器)

> **全自动化的暗网论坛监控与威胁情报推送工具**

厌倦了手动刷新暗网论坛来搜集威胁情报？我开发了这个自动化系统，利用 **OpenAI (GPT-4o)** 驱动的 AI 智能体，模仿人类行为浏览论坛，抓取帖子，自动检测关键威胁，并将研判后的高价值情报（含截图和摘要）直接推送到你的 Discord 频道。

这是一个致力于将繁琐的“人肉”监控转化为**智能化、自动化**流程的开源项目，旨在帮助网络安全人员从重复劳动中解脱出来，全天候掌握地下威胁动态。

<div align="center">

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://docker.com) [![AI](https://img.shields.io/badge/OpenAI-GPT_4o-412991?logo=openai)](https://openai.com) [![n8n](https://img.shields.io/badge/n8n-Automation-FF6D5A?logo=n8n)](https://n8n.io) [![Playwright MCP](https://custom-icon-badges.demolab.com/badge/Playwright_MCP-Browser_Automation-2EAD33?logo=playwright&logoColor=fff)](https://github.com/microsoft/playwright-mcp) [![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com) [![Discord](https://img.shields.io/badge/Discord-Integration-5865F2?logo=discord)](https://discord.com)

<img src="images/forum_posts_discord.png" alt="Discord 威胁情报推送预览" width="350">

</div>

## 🎯 痛点与解决方案

作为安全研究人员，手动监控暗网论坛往往面临诸多痛点：
- **⏰ 效率低下**：每天花费大量时间在多个论坛间切换检查。
- **🌙 遗漏风险**：睡觉或开会时容易错过稍纵即逝的关键情报。
- **📊 信息噪音**：海量灌水内容让人难以筛选出真正的高危数据泄露。
- **🛡️ 反爬对抗**：传统爬虫容易被论坛的验证码和反机器人机制拦截。

**DarkWeb Forums Tracker** 为此而生：

- ✨ **AI 智能拟人**：由 OpenAI (GPT-4o) 驱动的 AI 智能体，模拟人类浏览行为，降低被封风险。
- 🤖 **全自动工作流**：基于 n8n 编排，实现从抓取、分析到推送的全链路自动化。
- 📱 **实时情报推送**：发现关键词命中（如 "Database", "Leak"）时，立即发送包含截图和 AI 摘要的 Discord 警报。
- 🖥️ **人机协同 (VNC)**：遇到高难度验证码或首次登录时，可通过 VNC 界面远程介入，AI 随后自动接管。
- 🐳 **一键部署**：基于 Docker，只需一条指令即可启动整套监控系统。
- � **持续监控**：默认每 4 小时巡检一次，全天候不间断运行。

## 👥 适用人群

- **🛡️ SOC 团队**：作为外部威胁情报的早期预警源。
- **🕵️ 威胁猎手**：追踪黑客组织的最新动向、TTPs 和沟通渠道。
- **📡 情报分析师**：自动化收集地下数据，建立威胁数据库。
- **🔒 安全顾问/MSP**：为客户提供定制化的品牌保护和数据泄露监控服务。

## 🚀 快速开始

**前提条件**：已安装 Docker，且拥有 Supabase Cloud 账户、Discord Webhook 地址及 OpenAI API 密钥。

```bash
# 1. 克隆仓库
git clone https://github.com/brunosergi/darkweb-forums-tracker.git
cd darkweb-forums-tracker

# 2. 配置环境
cp .env.example .env
# 编辑 .env 文件，填入你的 Supabase 和 API 密钥等信息

# 3. 启动系统
docker compose up -d
# 系统会自动构建中文优化的 N8N 镜像并启动所有服务

# 4. 初始化
# 访问 http://localhost:5678 配置 N8N 凭证
# 激活预置的两个工作流，监控即刻开始！
```

> **📖 详细指南**：请参阅 [SETUP_CN.md](SETUP_CN.md) 获取保姆级配置教程。

**服务端口**：
- **N8N 管理面板**：`http://localhost:5678`
- **VNC 浏览器视图**：`http://localhost:6080`

## 🛠️ 核心架构

- **[n8n](https://n8n.io)**：自动化的大脑，负责调度和逻辑处理。
- **[Playwright MCP](https://github.com/microsoft/playwright-mcp)**：AI 驱动的浏览器，支持持久化会话和抗指纹检测。
- **[OpenAI (GPT-4o)](https://openai.com)**：智能分析核心，负责理解帖子内容并生成摘要。
- **[Supabase](https://supabase.com)**：云端 PostgreSQL + 对象存储，用于持久化数据和截图。
- **[Discord](https://discord.com)**：情报接收终端，支持富文本嵌入消息。

## 📋 工作流程

1. **🕵🏿 目标监控**：默认追踪 **DarkForums.io**（原 DarkForums.st），专注于数据库泄露板块。
2. **🕐 周期运行**：系统唤醒（默认每4小时）。
3. **🤖 智能解析**：AI 控制浏览器访问论坛，智能识别并提取帖子列表。
4. **🔍 去重过滤**：通过数据库比对，自动过滤已处理的历史帖子。
5. **🎯 关键词匹配**：根据设定的关键词（如企业名、泄露类型）进行精准筛选。
6. **� 证据留存**：对命中警报的帖子自动全屏截图。
7. **🧠 AI 研判**：GPT-4o 模型分析帖子内容，生成中文简报。
8. **📱 警报触达**：Discord 收到包含截图、摘要、链接和风险等级的警报。
9. **� 智能重试**：内置指数退避重试机制，应对网络波动或临时封锁。

## 🖥️ VNC 人机交互界面

自动化不是万能的，特别是在面对复杂的反爬措施时。本项目集成了 VNC 远程桌面功能：

### **应用场景**
- **手动过盾**：还是过不去 Cloudflare 或 DDoS-Guard？进去点一下就行。
- **首次登录**：需要输入账号密码或二次验证？手动登一次，Cookie 会自动保存。
- **调试排错**：直观看到 AI 到底卡在哪里了。

### **使用方法**
访问 **http://localhost:6080**，你将看到一个完整的 Chrome 浏览器界面。你可以直接操作这个浏览器，就像操作本地电脑一样。AI 智能体和你是共用这个浏览器的，它会接着你的操作继续执行。

<div align="center">
<img src="images/vnc_browser_interaction.png" alt="VNC 浏览器界面" width="500">
</div>

## 💡 功能亮点 (V1 版本)

- ✅ **本地化优化**：N8N 界面及工作流节点已全面汉化，更符合中文用户习惯。
- ✅ **智能重试**：包含 2 次智能重试机制，大幅提高监控稳定性。
- ✅ **实体识别**：支持配置实体别名库（如将 "fb", "meta" 统一识别为 Facebook）。
- ✅ **数据留存**：所有抓取记录和截图均持久化存储，便于后续回溯分析。
- ✅ **会话保持**：浏览器用户数据持久化挂载，登录态永不丢失（除非 Cookie 过期）。
- ✅ **分级推送**：普通更新静默记录，高危情报高亮警报。

## 🗺️ 未来规划

### 🏢 **覆盖范围扩展**
- 增加对 BreachForums, LockBit 博客, XSS.is 等高价值目标的监控支持。
- 优化长页面截图体验。

### 🤖 **对抗能力升级**
- **AI 自动过验证**：集成图像识别 AI，自动解决滑块和文字点选验证码。
- **代理池支持**：集成商业代理，支持 IP 轮换以规避封锁。
- **自动登录**：支持在 `.env` 中配置凭证，由 AI 自动完成登录过程。

### ⚡ **技术栈演进**
- **RAG 增强**：利用 Supabase pgvector 向量化存储帖子内容，构建暗网情报知识库。
- **多模型支持**：允许切换 OpenAI, Anthropic 等其他 LLM 提供商。
- **Tor 支持**：增加 Tor 网关，支持 .onion 暗网地址访问。

---

<div align="center">

**⭐ 如果这个项目对你的安全工作有帮助，请点个 Star 支持一下！**

[📖 部署教程](SETUP_CN.md) • [⚙️ 工作流文件](n8n/workflows)

*致敬每一位在网络安全前线奋斗的守望者 🛡️*

</div>
