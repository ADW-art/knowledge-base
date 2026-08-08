# AI 方向完整学习路线（目标：保研西电 · 人工智能方向）

> 适用人群：计算机大二，喜欢算法但非竞赛型选手，希望以项目+Kaggle+论文为主要竞争力。
> 更新日期：2026-08-06

---

## 路线总览

```
大一暑假 ──── 大二上 ──── 大二寒假 ──── 大二下 ──── 大二暑假 ──── 大三上
   │            │            │            │            │            │
   ▼            ▼            ▼            ▼            ▼            ▼
 Python      PyTorch    Kaggle入门    Kaggle冲牌   进实验室     发论文
 数学基础    经典模型    竞赛项目      Agent初探    论文精读     夏令营准备
 算法精学    NLP/CV      算法进阶      模型微调     竞赛包装     保研材料
```

---

## 第一阶段：基础夯实（现在 - 大二上学期）

### 1. Python 精通

**目标**：能用 Python 完成数据处理、模型训练脚本、自动化工具

| 资源 | 类型 | 链接/说明 |
|------|------|-----------|
| 《Python编程：从入门到实践》第3版 | 书籍 | 项目驱动，适合已有基础的快速过一遍 |
| Python官方Tutorial | 文档 | https://docs.python.org/zh-cn/3/tutorial/ |
| numpy官方快速入门 | 文档 | https://numpy.org/doc/stable/user/quickstart.html |

**检验标准**：能用 numpy/pandas 处理一个 10 万行的 CSV，完成清洗、统计、可视化。

### 2. 数学基础（按需补充，不要单独硬啃）

**原则**：不要在学模型之前把数学书从头啃完。在学模型的过程中，缺什么补什么。

| 主题 | 用到的时候学 | 最佳资源 |
|------|-------------|----------|
| 线性代数 | 学神经网络时 | 3Blue1Brown《线性代数的本质》 |
| 概率论与统计 | 学贝叶斯/损失函数时 | 《概率导论》(Bertsekas) 前 5 章 |
| 最优化 | 学梯度下降时 | 李宏毅 ML 课程第 2-3 讲 |
| 信息论 | 学交叉熵时 | Christopher Olah 博客 + 维基百科 |

**B站资源**：

| 课程 | 链接 | 说明 |
|------|------|------|
| 3Blue1Brown 线性代数的本质 | https://www.bilibili.com/video/BV1ys411472E | 15集，每集15分钟，先看这个再碰矩阵计算 |
| 3Blue1Brown 微积分的本质 | https://www.bilibili.com/video/BV1qW411N7FU | 理解梯度下降的前提 |
| 3Blue1Brown 神经网络 | https://www.bilibili.com/video/BV1bx411M7Zx | 4集，直观理解反向传播 |

### 3. 算法精学（研究模式，非竞赛模式）

**原则**：精选 30 道核心题，每道题花 1-2 小时吃透原理，输出一篇自己的讲解。

| 资源 | 类型 | 链接/说明 |
|------|------|-----------|
| 《算法导论》CLRS 第4版 | 书籍 | 当字典用，不要通读 |
| 《Hello 算法》 | 在线书 | https://www.hello-algo.com/ 图解 + 多语言实现，入门最佳 |
| 代码随想录 | 网站+B站 | https://programmercarl.com/ 按题型分类，适合系统性过一遍 |
| LeetCode Hot 100 | 刷题 | 精选 100 道，重点是吃透而非刷完 |

**B站资源**：

| 课程 | 链接 | 说明 |
|------|------|------|
| 代码随想录算法公开课 | https://space.bilibili.com/525438321 | Carl 的算法讲解，风格偏向讲透一道题 |
| MIT 6.006 算法导论（中文字幕） | https://www.bilibili.com/video/BV1fu41117dN | 经典课程，适合理解算法设计思想 |

**你的学习方法（针对"看过不能马上写出来"）**：

1. 读题 + 读题解（读 2-3 篇不同人的题解，理解不同思路）
2. 关上题解，用自己的话写一篇讲解（博客/Obsidian笔记）
3. 隔天不看任何东西，从头写一遍代码
4. 如果写不出来，标记这道题，一周后重复第 3 步

### 4. 第一个完整 AI 项目

**目标**：在学 PyTorch 的同时，做一个完整的端到端项目。你已有的 Codex 宠物项目已经是一个了，把它写成技术博客或项目报告。

**你想做的新项目方向**：
- 用 BERT 微调做文本分类（NLP入门首选）
- 用 ResNet 做图像分类（CV入门首选）
- 用你 Codex 宠物的 spritesheet 做一个小型生成模型

---

## 第二阶段：核心能力（大二寒假 - 大二下学期）

### 5. PyTorch + 深度学习系统学习

这是整个路线中**最重要的一步**。学完这一步，你就可以参加 Kaggle 和进实验室了。

**主线课程（三选一，按推荐顺序）**：

| 课程 | 链接 | 适合你吗 |
|------|------|----------|
| 李沐《动手学深度学习》d2l.ai | https://www.bilibili.com/video/BV1if4y147hS | ⭐ 首选！代码+理论同步，PyTorch 版，每一章都有可运行的 notebook |
| 李宏毅 ML 2024 | https://www.bilibili.com/video/BV1TD4y137mP | 台湾大学课程，讲解极其生动，适合喜欢直觉理解的人 |
| 吴恩达 Deep Learning Specialization | https://www.bilibili.com/video/BV1FT4y1E74V | 经典入门，但偏旧（TensorFlow 1.x），建议只看前三门课理解概念 |

**书籍**：

| 书籍 | 说明 |
|------|------|
| 《动手学深度学习》d2l.ai | 免费在线，跟李沐视频配套 |
| 《深度学习》(花书) Goodfellow | 当字典用，不要从头读 |
| 《统计学习方法》李航 | 面试前翻一遍，推导简洁 |

**检验标准**：能用 PyTorch 从零训练一个 CNN 做 CIFAR-10，达到 85%+ 准确率；能用 HuggingFace 微调 BERT 做文本分类。

### 6. HuggingFace 生态

这是 AI 方向的"GitHub"，必须会用。

| 资源 | 链接 |
|------|------|
| HuggingFace 官方课程 | https://huggingface.co/learn/nlp-course |
| HuggingFace NLP Course 中文翻译 | https://www.bilibili.com/video/BV1m94y1j7zK |

**学完的标准**：会加载预训练模型、tokenizer、Trainer API、push_to_hub。

### 7. Kaggle 入门 → 冲牌

| 阶段 | 比赛难度 | 目标 |
|------|----------|------|
| 入门 | Titanic、House Prices | 熟悉提交流程、baseline |
| 进阶 | Disaster Tweets (NLP)、Dogs vs Cats (CV) | 完整建模、调参、上分 |
| 冲牌 | 任选一个 Featured 比赛 | 争取拿银牌/铜牌 |

**B站 Kaggle 教程**：

| 资源 | 链接 | 说明 |
|------|------|------|
| 跟李沐学AI — Kaggle 实战 | https://space.bilibili.com/1567748478 | 李沐的 Kaggle 实战系列 |
| Kaggle 竞赛宝典 | https://www.bilibili.com/video/BV1kA4m1w7hZ | 入门向，讲竞赛策略和特征工程 |

**你的优势**：你的算法基础（debug耐力、代码速度）在 Kaggle 里是降维打击。Kaggle 选手大多代码写得慢、调参靠运气，你刷过题的手在调实验上会很快。

### 8. NLP or CV 选一个深耕

**建议 NLP**（与你已有的 Agent 经验衔接更好）：
- 学 transformer 架构彻底搞懂
- 微调 BERT → RoBERTa → Gemma → Qwen 等模型
- 学 prompt engineering + few-shot

**B站 NLP 进阶**：

| 资源 | 链接 | 说明 |
|------|------|------|
| 李沐 — Transformer 论文精读 | https://www.bilibili.com/video/BV1pu411o7BE | 逐行读论文，理解 attention |
| 李沐 — BERT 论文精读 | https://www.bilibili.com/video/BV1PL411M7eQ | NLP 里程碑论文 |
| Andrej Karpathy — Let's build GPT from scratch | https://www.bilibili.com/video/BV1cN4y1V7NU | 手写 GPT，理解 transformer 的最佳方式 |

---

## 第三阶段：加速期（大二暑假）

### 9. 进实验室

**时间点**：大二下学期期中之后开始联系老师，暑假正式进组。

**怎么联系**：
1. 打开学院官网，找做 AI/NLP/CV 的老师
2. 读他最近 2 年的论文，挑一篇你能大概看懂的
3. 发邮件："老师好，我是大二 XXX，读过您关于 XXX 的论文，对 XXX 方向感兴趣。我做过 XXX 项目（附 GitHub），希望能进实验室学习。"

**为什么你比其他人有优势**：你有 Codex 宠物项目和一个 Kaggle 记录。大部分大二学生发邮件的时候什么都拿不出来。

### 10. Agent / LangGraph / RAG（这时候才学）

等你能用 PyTorch 训练模型了，Agent 这些东西一周就能上手。

| 资源 | 链接 | 说明 |
|------|------|------|
| LangChain 官方文档 | https://python.langchain.com/docs | 看 Concepts 和 Tutorials |
| LangGraph 官方教程 | https://langchain-ai.github.io/langgraph/tutorials/ | Agent 编排框架 |
| DeepLearning.AI — Building Agentic RAG | https://www.deeplearning.ai/short-courses/ | Andrew Ng 的短课，2小时看完 |

### 11. 论文精读

**原则**：每周读 1-2 篇，精读（能复述核心思想和方法），不求多。

| 资源 | 链接 |
|------|------|
| 李沐 — 论文精读系列 | https://space.bilibili.com/1567748478 |
| Papers With Code | https://paperswithcode.com/ |
| arXiv 每日订阅 | https://arxiv.org/ 关注 cs.AI、cs.CL、cs.CV |

---

## 第四阶段：成果期（大三上学期）

### 12. 竞赛 / 论文产出

**竞赛**：
- 软件杯 A3 赛道 — 你已有的 Codex 宠物项目可以直接包装
- 计算机设计大赛 AI 赛道
- 数学建模国赛/美赛

**论文**：
- 跟实验室师兄合作，争取署名
- 如果有独立想法，写一篇 workshop 论文先试试

### 13. 保研准备

**夏令营材料**（大三下学期 3-5 月准备）：
- 个人陈述
- 简历（项目经历、竞赛奖项、论文）
- 推荐信（找实验室导师 + 任课老师）
- 机试准备（你之前的算法积累在这里变现）

**西电目标实验室/学院**：
- 智能感知与图像理解教育部重点实验室
- 计算机科学与技术学院 AI 方向
- 人工智能学院

---

## 持续事项（贯穿全程）

| 事项 | 频率 | 说明 |
|------|------|------|
| 算法刷题 | 每天 1 道（研究模式） | LeetCode Hot 100 + 剑指 Offer |
| GitHub 绿点 | 每周至少 3 次 commit | 项目代码、笔记、博客都算 |
| 技术博客 | 每两周一篇 | 算法讲解、项目复盘、论文笔记 |
| 英语 | 每天 30 分钟 | 六级 550+ 或雅思 6.5+ |
| 读论文 | 每周 1-2 篇 | 从 arXiv 和 Papers With Code 找 |

---

## 关键时间节点

| 时间 | 里程碑 |
|------|--------|
| 大二上结束 | PyTorch 熟练 + 一个完整的 DL 项目 + LeetCode 50 题 |
| 大二下结束 | Kaggle 银牌 + 一篇技术博客 + 联系好导师 |
| 大二暑假 | 进实验室 + 了解 Agent/RAG + 准备竞赛材料 |
| 大三上 | 竞赛奖项/论文 + 确定目标院校 + 夏令营材料 |

---

## 关于链接的说明

以上 B站/网站链接基于 2026 年 8 月可访问的资源整理。如果某个链接失效：

1. 在 B站直接搜索课程/UP主名称
2. 李沐的所有内容在 `space.bilibili.com/1567748478` 可以找到
3. d2l.ai 官网有最新视频链接
4. 3Blue1Brown 的官方中文频道持续更新

---

> **最后一句**：这个路线不是要你每一项都完美完成。它的核心逻辑是——先拿到训练模型的能力（PyTorch + Kaggle），再用这个能力去换实验室门票和竞赛奖项，最后用这些筹码去敲西电的门。你现在的 Codex 宠物项目已经是第一张牌了。
