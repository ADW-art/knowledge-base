---
created: 2026-07-17
updated: 2026-07-17
type: concept
tags: [ai, agent, llm, architecture]
aliases: [Agent架构, ReAct, Plan-and-Execute]
---

# Agent 架构模式

> **一句话**: Agent = LLM + 工具 + 记忆 + 行动循环

## 核心模式：ReAct (Reason + Act)

```
观察 (Observation) → 思考 (Thought) → 行动 (Action) → 观察 ...
```

### 工作流程
1. LLM 接收用户输入 + 当前上下文
2. LLM "思考"下一步该做什么
3. LLM 选择一个工具（Tool）并生成参数
4. 系统执行工具，返回结果
5. 结果作为新的观察送到 LLM
6. 循环直到任务完成

## 动手实现一个极简 Agent

```python
# Karpathy 式：从零理解 Agent 核心
import json

class SimpleAgent:
    def __init__(self, llm, tools):
        self.llm = llm
        self.tools = {t.name: t for t in tools}
    
    def run(self, task):
        messages = [{"role": "user", "content": task}]
        while True:
            response = self.llm.chat(messages)
            action = json.loads(response)
            if action["type"] == "final":
                return action["output"]
            tool = self.tools[action["tool"]]
            result = tool.run(action["args"])
            messages.append(response)
            messages.append({"role": "tool", "content": result})
```

## 对比不同框架

| 框架 | 特点 | 适用场景 |
|------|------|---------|
| LangChain | 生态最全，抽象层多 | 快速原型 |
| LangGraph | 有向图编排，灵活 | 复杂工作流 |
| AutoGen | 多 Agent 对话 | 协作任务 |
| CrewAI | 角色分工 | 团队模拟 |

## 🔗 关联概念
- [[LLM推理原理]] ← Agent 的"大脑"
- [[Tool Use与Function Calling]] ← Agent 的"手"
- [[MOC-AI与智能体]] ← 回到 AI 导航页
