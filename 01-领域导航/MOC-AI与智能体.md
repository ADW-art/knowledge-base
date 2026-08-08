---
created: 2026-07-17
updated: 2026-08-08
type: moc
aliases: [AI, 人工智能, 智能体, Agent]
---

# 🤖 AI 与智能体 · Map of Content

> **Karpathy 视角**: 不理解 Transformer？从零写一个 microGPT → 理解 Token 如何预测 → 扩展为真正可用的 Agent

## 🎯 学习路线

```mermaid
flowchart LR
    A[LLM原理] --> B[Prompt工程]
    B --> C[Agent框架]
    C --> D[多智能体系统]
    D --> E[生产化部署]
```

## 📍 当前重点：Agent 智能体搭建

- [[LLM推理原理|LLM 推理原理]]
- [[AI与智能体/Agent架构模式|Agent 架构模式（ReAct / Plan-and-Execute）]]
- [[Tool Use与Function Calling|Tool Use 与 Function Calling]]
- [[多Agent协作模式|多 Agent 协作模式]]
- [[机器人/Koishi机器人框架|Koishi 机器人框架与插件架构]]

## 📚 学习资源

- [[动手学深度学习笔记/VMware环境配置手册|VMware 上配置 d2l 环境 · 完整手册]]
- [[动手学深度学习笔记/python前置知识|动手学深度学习 · Python 前置知识]]

- [[动手学深度学习笔记/python前置知识|动手学深度学习 · Python 前置知识]]
- [[指南/Universal-Diagnostic-Tutor使用指南|Universal Diagnostic Tutor 使用指南]]

## 📂 概念笔记
```dataview
TABLE created as "创建", updated as "更新"
FROM "02-笔记/概念笔记" and #ai
SORT updated DESC
```

## 🛠️ 项目实战

- [[../03-项目/qq机器人项目优化|QQ 机器人项目优化]]

## 📡 Horizon 日报中的 AI 资讯
```dataview
TABLE date as "日期"
FROM "07-日报"
WHERE contains(file.name, "zh")
SORT file.name DESC
LIMIT 5
```

## 🔗 关联领域
- [[MOC-网安|🔐 AI 安全（AI Agent 的安全性）]]
- [[MOC-计算机通识|💻 Python / 系统工程]]
