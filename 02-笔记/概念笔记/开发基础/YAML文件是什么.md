---
created: 2026-07-19
updated: 2026-07-19
type: concept
tags: [format, yaml, config]
aliases: [YAML, 配置文件格式, Yet Another Markup Language]
---

# YAML 文件是干什么的

> **一句话**: YAML 是一种写配置文件的格式，比 JSON 更易读，比 XML 更简洁。

---

## 你已经在用了

你不知不觉已经接触了很多 YAML 文件：

| 文件 | 作用 |
|------|------|
| `魔戒.net` | 机场订阅（代理节点列表） |
| `config.yaml` | FlClash / Clash Party 配置 |
| `daily-summary.yml` | GitHub Actions 工作流 |
| `.github/workflows/*.yml` | 自动化流程定义 |

---

## YAML 长什么样

最基本的结构就三种：

### 键值对

```yaml
name: "Horizon"
version: "1.0"
```

等价于 JSON：`{"name": "Horizon", "version": "1.0"}`

### 列表（数组）

```yaml
proxies:
  - 香港-01
  - 日本-01
  - 新加坡-01
```

等价于 JSON：`{"proxies": ["香港-01", "日本-01", "新加坡-01"]}`

### 嵌套

```yaml
ai:
  provider: deepseek
  model: deepseek-chat
  temperature: 0.3
```

等价于 JSON：`{"ai": {"provider": "deepseek", "model": "deepseek-chat", "temperature": 0.3}}`

---

## 为什么用 YAML 而不是 JSON

| | YAML | JSON |
|--|------|------|
| 可读性 | 更好（没有花括号） | 一般 |
| 注释 | ✅ 支持 `#` 注释 | ❌ 不支持 |
| 多行字符串 | ✅ 优雅支持 | ❌ 只能转义 |
| 写起来 | 轻松 | 容易漏逗号 |
| 解析速度 | 慢一点 | 快 |

你用 Clash 配置时应该能感受到——整个文件纯靠缩进就能看懂结构：

```yaml
proxies:                  # 代理列表
  - name: 香港-01           # 第一个节点
    type: vmess
    server: hk.example.com
  - name: 日本-01           # 第二个节点
    type: hysteria2
    server: jp.example.com

proxy-groups:             # 代理组
  - name: PROXY
    type: select
    proxies:
      - 香港-01
      - 日本-01
```

---

## 缩进就是语法

YAML 用**空格缩进**表示层级，不能用 Tab。

```yaml
parent:
  child: value    # ✅ 两个空格缩进
   child: value   # ❌ Tab 缩进，会报错
```

混用 Tab 和空格是 YAML 最常见的报错原因。

---

## YAML 在你的工具链中的位置

```text
机场服务器
    ↓ 返回 YAML 格式的订阅
Clash Party 读取并解析
    ↓ 把节点显示在界面上
你选一个节点
    ↓
mihomo 核心用这份配置建立连接
```

GitHub Actions 也一样：

```yaml
# .github/workflows/daily-summary.yml
name: Daily Horizon Summary
on:
  schedule:
    - cron: '0 22 * * *'
jobs:
  daily-summary:
    runs-on: windows-latest
    steps:
      - run: python -m src.main
```

这个文件定义了"什么时候触发、用什么机器、跑什么命令"——全是 YAML 描述的。

---

## 关联笔记
- [[Clash定位与订阅原理]] ← YAML 是 Clash 的配置语言
- [[GitHub Actions 入门]] ← YAML 定义了整个自动化流程
