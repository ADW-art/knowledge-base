---
created: 2026-07-19
updated: 2026-07-19
type: concept
tags: [devops, github, ci, automation]
aliases: [GitHub Actions, CI/CD, 定时任务]
---

# GitHub Actions 入门

> **一句话**: GitHub Actions = GitHub 白送你一台云服务器，到点自动跑你写的脚本。

---

## 最直观的理解

传统做法：
1. 买一台 VPS，每月花钱
2. 装环境、配 crontab
3. 维护服务器

GitHub Actions 的做法：
1. 把代码推到 GitHub
2. 放一个 `.yml` 配置文件
3. 不用管了

**GitHub 替你跑，不要钱，不用维护。**

---

## 核心概念

### Workflow

一个 `.yml` 文件定义一个工作流，放在 `.github/workflows/` 目录下：

```yaml
name: Daily Horizon Summary
on:
  schedule:
    - cron: '0 22 * * *'    # 每天 UTC 22:00 = 北京 06:00
  workflow_dispatch:         # 也支持手动触发

jobs:
  daily-summary:
    runs-on: ubuntu-latest   # 在 Ubuntu 上跑
    steps:
      - uses: actions/checkout@v6  # 拉代码
      - run: echo hello world
```

### 三个关键部分

```yaml
on:          # 触发器 —— 什么时候跑
jobs:        # 任务列表 —— 要做什么
steps:       # 每个任务的步骤 —— 怎么做
```

---

## 触发器（on）

### 定时任务（cron）

```yaml
on:
  schedule:
    - cron: '0 22 * * *'
```

cron = 5 个字段：`分钟 小时 日期 月份 星期`

**UTC 时区陷阱**：北京 06:00 = UTC 22:00（前一天）

### 手动触发

```yaml
on:
  workflow_dispatch:    # GitHub 网页上点按钮就能跑
```

---

## Runner：在哪跑

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
```

可选：`ubuntu-latest` / `windows-latest` / `macos-latest`

每次运行都是**全新的虚拟机**，跑完自动销毁。

---

## Steps：怎么跑

```yaml
steps:
  - uses: actions/checkout@v6       # 用现成的 Action
  - name: Install deps
    run: pip install -r requirements.txt
  - name: Run script
    run: python main.py
    env:
      API_KEY: ${{ secrets.API_KEY }}   # 从 Secrets 读取
```

### uses vs run

| | uses | run |
|--|------|-----|
| 作用 | 调用别人写好的 Action | 自己写命令 |
| 举例 | actions/checkout@v6 | run: python main.py |

版本号要写完整的：`@v8.3.2` ✅

---

## Secrets：安全传递密钥

```yaml
env:
  DEEPSEEK_API_KEY: ${{ secrets.DEEPSEEK_API_KEY }}
```

在 GitHub 网页设置：`Settings -> Secrets and variables -> Actions -> New repository secret`

- 加密存储
- 运行时自动解密注入
- 日志里自动用 *** 遮盖

---

## 日志查看

Actions 页面 -> 点某个运行记录 -> 点 job -> 展开 steps

每步输出实时显示，报错红色高亮。

---

## 我们踩过的坑

| 问题 | 原因 | 修复 |
|------|------|------|
| setup-uv@v6 不存在 | 版本号错 | 改为 @v8.3.2 |
| setup-uv@v8 也不存在 | 大版本标签没创建 | 改为 @v8.3.2 |
| uv.lock 有本地路径 | 锁了 E:/code/... | 改为 uv pip install -e . |

---

## 总结

GitHub Actions 的本质：**把代码 + 配置文件交给 GitHub，到点自动开虚拟机跑脚本，跑完关掉，免费。**

---

## 关联笔记
- [[自动化日报系统原理拆解]]
