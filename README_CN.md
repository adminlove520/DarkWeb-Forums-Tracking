# 🕵️ DarkWeb Forums Tracker

> **我构建的一个自动监控暗网论坛并将威胁情报警报发送到Discord的工具**

厌倦了手动检查暗网论坛获取威胁情报？我创建了这个自动化系统，它使用AI代理抓取论坛帖子，检测关键词警报，并直接将专业威胁情报发送到你的Discord。这是我的个人作品集项目，但我希望它能帮助其他网络安全人员在不需要手动工作的情况下了解地下活动。

<div align="center">

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://docker.com) [![AI](https://img.shields.io/badge/Google_Gemini-AI-FF6B35?logo=googlegemini)](https://ai.google.dev) [![n8n](https://img.shields.io/badge/n8n-Automation-FF6D5A?logo=n8n)](https://n8n.io) [![Playwright MCP](https://custom-icon-badges.demolab.com/badge/Playwright_MCP-Browser_Automation-2EAD33?logo=playwright&logoColor=fff)](https://github.com/microsoft/playwright-mcp) [![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com) [![Discord](https://img.shields.io/badge/Discord-Integration-5865F2?logo=discord)](https://discord.com)

<img src="images/forum_posts_discord.png" alt="DarkWeb Forums Discord Feed" width="350">

</div>

## 🎯 我解决的问题

在花费了太多时间手动监控暗网论坛获取威胁情报后，我意识到我们都面临着同样的挫折：

- **⏰ 手动监控耗时太长** - 每天检查多个论坛会占用你的时间
- **🌙 容易错过重要内容** - 关键帖子会在你睡觉或忙碌时出现
- **📊 信息过载** - 数百个帖子，没有好的方法来优先处理重要内容
- **🔄 每天重复同样的例行工作** - 一遍又一遍地手动检查同一个论坛
- **📱 难以与团队分享** - 截图和复制粘贴无法扩展
- **🛡️ 隐身需求** - 论坛会检测并阻止自动化爬虫

## 💡 我构建的解决方案

所以我构建了这个**DarkWeb Forums Tracker**来自动化繁琐的监控例行工作：

✨ **AI进行监控** - 由Google Gemini提供支持的代理以类似人类的行为抓取论坛  
🤖 **工作流处理一切** - n8n自动编排整个论坛监控流程  
📱 **Discord传递警报** - 实时通知，带有关键词匹配的截图  
🖥️ **人工干预** - VNC界面允许手动干预解决CAPTCHA和登录挑战  
🐳 **易于设置** - 只需运行 `docker compose up -d` 即可开始监控论坛  
🕐 **每4小时一次** - 一劳永逸的自动化，全天候运行  

## 👥 谁可能会发现这有用

如果你正在处理威胁情报监控，这可能会有所帮助：

- **🛡️ SOC团队** - 新兴威胁的早期预警系统
- **🕵️ 威胁猎手** - 监控威胁行为者通信和TTP
- **📡 威胁情报分析师** - 自动化暗网数据收集
- **👁️ 安全经理** - 地下活动的执行摘要  
- **🔒 安全顾问** - 为客户提供威胁情报服务
- **🏢 MSP团队** - 监控针对客户行业的威胁

## 🚀 快速开始

**前提条件**：Docker、Supabase Cloud账户、Discord webhook、Google Gemini API密钥

```bash
# 克隆并设置
git clone https://github.com/brunosergi/darkweb-forums-tracker.git
cd darkweb-forums-tracker
cp .env.example .env

# 使用Supabase和API凭证配置你的.env
# 启动平台
docker compose up -d

# 在 http://localhost:5678 配置N8N凭证
# 激活两个工作流并开始监控！
```

> **📖 完整设置指南**：请参阅 [SETUP_CN.md](SETUP_CN.md) 获取详细的分步配置

**服务**：N8N (5678) • VNC (6080) • 每4小时发送一次Discord警报

## 🛠️ 技术栈

### 核心工具
- **[n8n](https://n8n.io)** - 连接一切的可视化工作流
- **[Playwright MCP](https://github.com/microsoft/playwright-mcp)** - 具有隐身功能的AI驱动浏览器自动化
- **[Google Gemini](https://ai.google.dev)** - 读取和分析论坛内容的LLM
- **[Supabase](https://supabase.com)** - 带有文件存储的云PostgreSQL数据库
- **[Discord Webhooks](https://discord.com)** - 你的团队获取实时警报的地方
- **[Docker](https://docker.com)** - 所有内容都在容器中运行

### 论坛来源

## 📋 工作原理

1. **🕵🏿 DarkForums.st** - 跟踪数据库泄露和漏洞讨论
2. **🕐 定时监控** - 系统每4小时检查一次配置的论坛
3. **🤖 AI代理解析** - Playwright MCP通过浏览器自动化提取论坛帖子和时间戳
4. **🔍 智能去重** - 只处理新帖子（数据库中没有重复内容）
5. **🎯 实体检测** - 高级关键词匹配，带有规范名称、变体和文本标准化
6. **🔄 重试逻辑** - 2次尝试重试系统，带有智能退避机制，用于处理失败的操作
7. **📸 截图和分析** - 对于警报：捕获截图并生成AI摘要
8. **📱 Discord传递** - 全面的日志记录，带有彩色编码的警报和详细的状态更新
9. **💾 数据库存储** - 增强的架构，带有timestampz格式和实体跟踪

## 🖥️ 人工干预VNC界面

### **常见场景**
- **CAPTCHA解决**：AI在DDoS-Guard或论坛CAPTCHA上卡住
- **手动登录**：首次登录受保护的论坛
- **机器人检测**：绕过需要人工交互的反机器人措施
- **会话恢复**：当登录会话过期时重新认证

### **工作原理**
1. **AI代理运行**：Playwright MCP浏览器自动化正在进行中
2. **检测到挑战**：代理遇到CAPTCHA或登录要求
3. **手动干预**：连接到VNC并解决挑战
4. **AI继续**：代理在手动帮助后恢复自动抓取

VNC界面运行完整的Chrome浏览器，你可以看到AI代理看到的内容，并与任何需要人工输入的元素进行交互。

<div align="center">

<img src="images/vnc_browser_interaction.png" alt="VNC Browser Interface - AI Agent Forum Access" width="500">

</div>

<div align="center">

<img src="images/vnc_manual_captcha.png" alt="VNC Manual Captcha Solving" width="350" style="margin-right: 10px;">
<img src="images/vnc_manual_login.png" alt="VNC Manual Login" width="350">

</div>

### **快速手动访问**

当你需要手动控制浏览器进行故障排除、认证或CAPTCHA解决时：

**VNC Web界面**：访问 http://localhost:6080
- 按下 **Alt+F2** 并输入：`chromium`
- 或右键点击桌面 → 应用程序 → 运行终端并输入：`chromium &`

**容器终端**：
```bash
docker exec -it darkweb-forums-tracker-playwright bash
chromium &
```

非常适合解决CAPTCHA、设置认证cookie、调试失败的抓取或手动导航AI代理无法自动处理的复杂登录流程。

## 💡 V1 MVP功能

✅ **定时触发器** - 每4小时开始一次  
✅ **Discord通知** - 发送扫描开始信息（如果出现问题，有助于引起人工注意）  
✅ **论坛URL循环** - 给定论坛URL进行迭代  
✅ **AI代理扫描** - 扫描循环中的当前URL目标  
✅ **错误处理** - 如果循环成功 → 继续工作流，如果循环失败 → 失败分支（bot_captcha, login_needed等）  
✅ **去重** - 删除重复帖子  
✅ **关键词分支分离** - 以数组格式将关键词添加到"Keywords"节点（用户可自定义）  
✅ **警报工作流** - 如果包含任何关键词 → 警报分支（截图+AI摘要），如果没有关键词 → 正常分支  
✅ **人工干预VNC** - 基于Web的浏览器GUI，用于手动解决CAPTCHA和登录协助  
✅ **共享浏览器会话** - VNC和Playwright MCP使用相同的Chromium可执行文件，带有共享用户数据目录，用于持久化登录会话  
✅ **AI代理重试逻辑** - 2次尝试重试系统，带有智能退避机制和Discord通知  
✅ **增强的实体检测** - 智能关键词匹配，带有规范名称、变体和文本标准化  
✅ **时间戳格式标准化** - 所有日期以timestampz格式存储，用于正确的时间分析  
✅ **高级Discord日志记录** - 全面的状态跟踪，带有彩色编码的警报和详细的错误报告  
✅ **数据库存储** - 保存所有内容，用于历史分析和跟踪
✅ **Discord结果** - 使用基于实体的检测，将正常帖子和警报帖子区分开来发送到Discord  

## 🗺️ 我接下来的计划

### 🏢 **论坛和数据改进**
- **多论坛支持** - 跟踪漏洞论坛、lockbit、xss.is等
- **截图前向下滚动一点** - 获得更好的视图
- **模块化工作流** - 将工作流分解为多个工作流，以分离关注点

### 🤖 **认证和反机器人**
- **解决验证码和登录子工作流工具** - 调用AI代理自动处理
- **Discord通知** - 当出现验证码/论坛阻塞时，请求人工干预
- **商业/住宅代理** - 支持解决反机器人问题（IP轮换、验证码解决器）
- **AI代理自动登录** - 在.env中提供论坛凭证，供AI代理使用


### ⚡ **技术增强**
- **AI代理N8N模型选择器** - 定义使用哪个LLM和AI代理回退方案
- **第二个AI代理重试逻辑** - 将相同的2次尝试重试系统应用于警报帖子分析工作流
- **pg_vector** - 向量化Supabase数据，并将论坛帖子转换为用于AI聊天的RAG
- **更好的定时触发器** - 为每个论坛URL路径配置分钟/小时
- **Tor代理** - 访问.onion论坛
- **更多通知应用** - Slack、Telegram等

这些功能将把它从一个简单的论坛监控器转变为一个全面的暗网威胁情报平台。目标是让它足够可靠，以至于安全团队实际上依赖它进行地下威胁检测。

---

<div align="center">

**⭐ 如果你觉得有用，请给这个仓库加星！**

[📖 设置指南](SETUP_CN.md) • [⚙️ 工作流](n8n/workflows)

只是一个为网络安全社区构建工具的人 🛡️

</div>