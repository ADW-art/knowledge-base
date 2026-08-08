---
created: 2026-07-17
type: moc
aliases: [网络安全, Security, 网安]
---

# 🔐 网络安全 · Map of Content

> **Karpathy 视角**: 安全领域是最适合"动手造"的——搭一个靶场 → 亲自打一遍 → 写自己的工具 → 变成自动化脚本

## 🎯 学习路线

```mermaid
flowchart LR
    A[Web基础] --> B[漏洞原理]
    B --> C[渗透测试]
    C --> D[红队技术]
    D --> E[安全工具开发]
    E --> F[CTF实战]
```

## 📍 当前重点：红队方向

- [[渗透测试流程|渗透测试流程]]
- [[常见漏洞类型|常见漏洞类型（OWASP Top 10）]]
- [[信息收集方法论|信息收集方法论]]
- [[内网渗透基础|内网渗透基础]]

## 📂 概念笔记
```dataview
TABLE created as "创建", updated as "更新"
FROM "02-笔记/概念笔记" and #security
SORT updated DESC
```

## 🛠️ 项目实战
```dataview
TABLE status as "状态"
FROM "04-项目" and #security
SORT status DESC
```

## 📚 学习资源
- [[05-资源/书籍#安全|安全相关书籍]]
- [[05-资源/课程#安全|安全课程]]
- [[05-资源/工具链#安全|安全工具链]]

## 🔗 关联领域
- [[MOC-AI与智能体|🤖 AI 安全应用（AI驱动的安全工具）]]
- [[MOC-计算机通识|💻 网络协议基础]]
