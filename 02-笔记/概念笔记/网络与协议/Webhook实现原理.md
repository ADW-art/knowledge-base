---
created: 2026-07-17
updated: 2026-07-17
type: concept
tags: [web, protocol, http, api, feishu]
aliases: [Webhook原理, HTTP回调, 消息推送]
---

# Webhook 实现的技术原理

> 一句话：Webhook = **有消息时主动给你发一条 HTTP POST 请求**

---

## 1. Webhook 是什么

### 对比两种通信模式

```
轮询 (Polling):     你 → 每隔几秒问一次 → 服务器 → "没新消息" × N 次
Webhook (回调):     服务器 → 有新消息时主动 POST → 你（只一次）
```

Webhook 的核心思想是 **反向 API**——不需要你一直去问，有消息了系统自然会推给你。

### 生活中类比

- **轮询** = 你每 5 分钟去收件箱看一眼有没有新邮件
- **Webhook** = 邮递员到你家门口按门铃，你把信拿走

---

## 2. 技术本质：一条 HTTP POST 请求

Webhook 没有任何神秘之处，它就是一个**标准的 HTTP POST 请求**：

```
POST /open-apis/bot/v2/hook/xxx HTTP/1.1
Host: open.feishu.cn
Content-Type: application/json; charset=utf-8

{ "msg_type": "interactive", "card": {...} }
```

### 与普通浏览器请求的唯一区别

| | 普通 HTTP | Webhook |
|--|-----------|---------|
| 方向 | 客户端 → 服务器（请求数据） | 服务器 → 客户端（推送数据） |
| 频率 | 用户主动触发 | 事件驱动（有消息才发） |
| 接收方 | 人类（浏览器渲染） | 机器（API 端点） |
| 格式 | HTML 页面 | JSON 结构化数据 |

### HTTP 状态码的意义

- `200 OK`：飞书收到了，卡片显示正常
- `400 Bad Request`：JSON 格式错了，飞书看不懂
- `403 Forbidden`：Webhook URL 无效或已失效
- `429 Too Many Requests`：发太快了，被限流

---

## 3. 飞书卡片消息的 JSON 结构

飞书自定义机器人支持两种消息格式：

### 纯文本（最简单）
```json
{
    "msg_type": "text",
    "content": { "text": "你好" }
}
```

### 交互式卡片（我们用这个）
```json
{
    "msg_type": "interactive",
    "card": {
        "schema": "2.0",
        "config": { "wide_screen_mode": true },
        "header": {
            "title": { "tag": "plain_text", "content": "标题" },
            "template": "blue"
        },
        "body": {
            "elements": [
                { "tag": "markdown", "content": "**加粗** 普通 列表等" },
                { "tag": "hr" },
                { "tag": "markdown", "content": "更多内容" }
            ]
        }
    }
}
```

### 可用的 Element 类型

| tag | 作用 | 示例 |
|-----|------|------|
| `markdown` | 富文本内容 | 支持 **粗体**、列表、链接 |
| `hr` | 分割线 | 视觉分隔不同区域 |
| `button` | 可交互按钮 | 打开链接、回传数据 |
| `column_set` | 多列布局 | 并排显示内容 |
| `note` | 备注文字 | 灰色小字说明 |

### Horizon 用的折叠面板（collapsible）

Horizon 使用了飞书 2.0 卡片协议中的折叠面板，每条新闻是一个可展开的项：

```
┌─────────────────────────────────────┐
│  Horizon 每日速递 - 2026-07-16      │  ← header
├─────────────────────────────────────┤
│  从 175 条中筛选 13 条               │  ← overview
├─────────────────────────────────────┤
│  ▼ 1. Windows 0-day 漏洞...  ⭐ 9/10 │  ← collapsible panel 1
│  ▼ 2. Thinking Machines Lab... ⭐ 9/10│  ← collapsible panel 2
│  ▼ 3. Zoom 漏洞...          ⭐ 8/10 │  ← collapsible panel 3
│  ...                                 │
├─────────────────────────────────────┤
│  ---                                 │  ← hr
│  **技术专题**                         │  ← tech deep-dive
│  Rust 语言详解...                     │
└─────────────────────────────────────┘
```

折叠面板在 JSON 中表示为：

```python
_collapsible_panel(title, content)
# 返回的结构让飞书渲染为可点击展开的卡片
```

---

## 4. Horizon 的 Webhook 实现链路

### 代码层级

```
orchestrator.py                          ← 工作流编排
    ↓ summary（完整 Markdown 文本）
webhook.py: send_daily_summary()        ← 入口
    ↓
build_daily_summary_messages()          ← 按平台选择格式
    ↓ if platform == feishu + layout == collapsible
_build_feishu_collapsible_body()        ← 组装卡片 JSON
    ↓
    _build_feishu_collapsible_overview() ← 头部文字
    ↓ for each item...
    generate_webhook_item()              ← 每条新闻的 Markdown
    ↓
    _collapsible_panel()                 ← 包装成折叠面板
    ↓ append tech deep-dive 部分
httpx POST → 飞书服务器                    ← 实际发出
```

### 关键数据结构

```python
# 1. 变量模板（#{var} 会在运行时替换）
variables = {
    "summary": "...",           # 完整日报 Markdown（含技术专题）
    "date": "2026-07-16",
    "important_items": 13,
    "all_items": 175,
    "language": "zh",
}

# 2. 消息载体
messages = [
    {
        "message_title": "Horizon 2026-07-16 折叠日报",
        "message_kind": "collapsible",
        "summary": "从 175 条中筛选出 13 条...",
        "_request_body_override": {   # 完整的飞书卡片 JSON
            "msg_type": "interactive",
            "card": { ... }
        }
    }
]

# 3. 实际发出的 HTTP 请求
httpx.post(feishu_url, json=card_json)
```

---

## 5. 环境变量与密钥安全

Webhook URL 包含了机器人的身份凭证，不能写在代码里。

### 双重分离策略

```
┌────────────────┐     ┌──────────────┐
│  代码仓库      │     │  本地环境     │
│                │     │              │
│ config.json    │     │ .env         │
│ url_env:       │  →  │ HORIZON_     │
│ "HORIZON_      │     │ WEBHOOK_URL  │
│  WEBHOOK_URL"  │     │ = https://...│
│                │     │              │
│  提交到 GitHub │     │ .gitignore   │
│                │     │ 不提交       │
└────────────────┘     └──────────────┘
```

- 代码里只写**环境变量名**（`url_env: "HORIZON_WEBHOOK_URL"`）
- 实际 URL 在 `.env` 文件（本地）或 GitHub Secrets（CI）
- Webhook 处理函数中通过 `os.getenv("HORIZON_WEBHOOK_URL")` 取值

---

## 6. FlClash 代理与网络排查

### 为什么 webhook 不通？

| 问题 | 现象 | 原因 |
|------|------|------|
| 代理端口错 | `127.0.0.1:7897` 连接拒绝 | 系统代理走 7890，Git 配置的 7897 没开 |
| Hosts 劫持 | GitHub 上不去 | `hosts` 文件写死了旧 IP，覆盖 DNS |
| 容器网络隔离 | 沙箱里 `127.0.0.1:7890` 不通 | 沙箱和宿主机各有自己的 loopback |
| 证书错误 | `ERR_SSL_VERSION_OR_CIPHER_MISMATCH` | 代理拦截了 GitHub 的 HTTPS 连接 |

### 排查工具链

```bash
# 检查端口是否在监听
netstat -ano | findstr ":7890 "

# 测试代理是否通
curl --proxy http://127.0.0.1:7890 https://github.com

# 查看进出连接
netstat -ano | findstr "ESTABLISHED"

# 查谁占用了端口
Get-Process -Id <PID>
```

---

## 7. 知识点延伸

### 如果飞书换成其他平台

不同平台的自定义机器人 Webhook 只是**请求体 JSON 格式**不同：

```python
# 飞书：interactive card
{"msg_type": "interactive", "card": {...}}

# 钉钉：markdown
{"msgtype": "markdown", "markdown": {"title": "...", "text": "..."}}

# Slack：blocks
{"text": "...", "blocks": [...]}

# Discord：embeds
{"embeds": [{"title": "...", "description": "..."}]}
```

但底层的**通信方式完全一致**——都是 HTTP POST + JSON。

---

## 🔗 关联笔记
- [[自动化日报系统原理拆解]] ← 整套系统的架构全貌
- [[从代码到执行]] ← HTTP 协议在底层的传输过程
