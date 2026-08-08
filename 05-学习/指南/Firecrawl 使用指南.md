# Firecrawl 使用指南

## 是什么

Firecrawl 是一个网页抓取/搜索 API 服务，能把网站内容转换成 LLM 可用的结构化数据（Markdown、JSON 等）。核心价值：网页 → 干净文本，不用自己写爬虫。

## 本机配置

```bash
# 1. CLI（npx 即用）
npx -y firecrawl-cli@latest

# 2. API Key（已持久化）
# 环境变量: FIRECRAWL_API_KEY
# 或写入 E:\code\知识库\.env

# 3. Codex MCP（已注册，OAuth 已认证）
codex mcp add firecrawl --url https://mcp.firecrawl.dev/v2/mcp-oauth
```

配置位置：

- CLI 配置：`C:\Users\18534\AppData\Roaming\firecrawl-cli`
- Codex MCP：`C:\Users\18534\.codex\config.toml` 的 `[mcp_servers.firecrawl]`
- 缓存目录：`.firecrawl/`（已加入 .gitignore）

## 常用命令

```bash
# 网页搜索（当搜索引擎用）
firecrawl search "关键词" --limit 5

# 抓取单个页面
firecrawl scrape https://example.com

# 爬取整个站点
firecrawl crawl https://docs.example.com

# 站点 URL 地图
firecrawl map https://example.com

# AI agent 模式：给任务，自动搜索+总结
firecrawl agent "搜索XX并总结方案"

# 解析本地文件（HTML/PDF/DOCX 等转 Markdown）
firecrawl parse report.pdf

# 监控页面变化/定时抓取
firecrawl monitor
```

## 在 Codex 中触发

Firecrawl MCP 工具在新会话中可用，工具名类似：

- `mcp__firecrawl__search` - 搜索
- `mcp__firecrawl__scrape` - 抓取
- `mcp__firecrawl__crawl` - 爬站
- `mcp__firecrawl__extract` - 结构化提取

直接说"==**用 firecrawl 搜 XXX**=="即可触发。若当前会话未加载，新开一个会话。

## 成本

- 免费额度：1000 credits/月
- 每 credits 对应一次 API 请求（scrape/search/crawl 各自计价）
- 超量后需付费（firecrawl.dev 按量计费）

## 适用场景

- 查技术文档/开源项目
- 抓取网页正文做知识库素材
- 定时监控网页更新
- 让 AI 搜索并总结外部信息
