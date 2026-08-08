# 动手学深度学习（d2l.ai）前置知识笔记

> 适用于李沐《动手学深度学习》v2 版（PyTorch）
> 目标：开课前补齐真正会用到的 Python/NumPy/数学基础，避免学一半卡在工具上

---

## 一、Python 核心（课程中最常用到的部分）

### 1.1 列表推导式

d2l 里大量构造数据，列表推导式比 for 循环更常见：

```python
# 基础
squares = [x**2 for x in range(10)]

# 带条件
evens = [x for x in range(20) if x % 2 == 0]

# 嵌套——构造二维数据时常用
matrix = [[i * j for j in range(5)] for i in range(5)]
```

### 1.2 切片操作

训练时切 batch、取前 N 个样本，全靠切片：

```python
data = list(range(100))
first_10 = data[:10]      # 前10个
last_10 = data[-10:]      # 后10个
every_other = data[::2]   # 每隔一个
reversed_data = data[::-1] # 反转
```

### 1.3 函数式编程：`map` / `filter` / `lambda`

数据预处理和 pipeline 中常见：

```python
# lambda：一次性小函数
square = lambda x: x**2

# map：对每个元素做变换
nums = [1, 2, 3, 4]
squared = list(map(lambda x: x**2, nums))  # [1, 4, 9, 16]

# filter：按条件筛选
evens = list(filter(lambda x: x % 2 == 0, nums))  # [2, 4]

# zip：配对迭代——训练时遍历 (特征, 标签) 对
features = [1, 2, 3]
labels = [10, 20, 30]
for x, y in zip(features, labels):
    print(x, y)
```

### 1.4 `enumerate` 与索引

```python
# 同时拿索引和值
for i, val in enumerate(['a', 'b', 'c']):
    print(i, val)  # 0 a, 1 b, 2 c
```

### 1.5 生成器与 `yield`

读大文件、逐 batch 取数据时用，不一次性加载全部：

```python
def batch_generator(data, batch_size):
    for i in range(0, len(data), batch_size):
        yield data[i:i + batch_size]

# 用起来像迭代器
for batch in batch_generator(range(100), 10):
    pass  # 每次拿到10个
```

### 1.6 类与继承（PyTorch `nn.Module` 的基础）

d2l 里所有模型都继承 `nn.Module`，理解类的基本语法就够了：

```python
class MyModel:
    def __init__(self, param):
        self.param = param          # 成员变量

    def forward(self, x):
        return x * self.param       # 方法
```

不需要深入多重继承、元类、装饰器等高级特性。

### 1.7 文件读写

```python
# 读文本
with open('data.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# 逐行读
with open('data.txt', 'r', encoding='utf-8') as f:
    for line in f:
        print(line.strip())

# 写文件
with open('output.txt', 'w', encoding='utf-8') as f:
    f.write('hello')
```

### 1.8 `*args` 与 `**kwargs`

d2l 工具函数中大量使用：

```python
def func(*args, **kwargs):
    print(args)      # 位置参数 -> 元组
    print(kwargs)    # 关键字参数 -> 字典

func(1, 2, lr=0.01, epochs=10)
# (1, 2)
# {'lr': 0.01, 'epochs': 10}
```

### 1.9 `@property` 装饰器（了解即可）

在定义数据加载器时偶尔遇到：

```python
class Dataset:
    @property
    def size(self):
        return len(self.data)
```

---

## 二、NumPy 核心（PyTorch tensor 的"前世"）

> PyTorch tensor API 几乎复刻 NumPy。NumPy 会了，tensor 就只剩"搬到 GPU"这一步。

### 2.1 创建数组

```python
import numpy as np

a = np.array([1, 2, 3])                # 从列表创建
b = np.zeros((3, 4))                   # 全零矩阵
c = np.ones((2, 3))                    # 全一矩阵
d = np.arange(12).reshape(3, 4)        # 从0到11，排成3行4列
e = np.random.randn(3, 4)              # 标准正态分布随机数
f = np.random.uniform(0, 1, (3, 4))    # 均匀分布 [0,1)
```

### 2.2 数组属性

```python
arr = np.arange(24).reshape(2, 3, 4)
arr.shape      # (2, 3, 4) —— 每个维度的大小
arr.ndim       # 3 —— 几维
arr.dtype      # dtype('int64') —— 元素类型
arr.size       # 24 —— 总元素数
```

### 2.3 索引与切片

```python
arr = np.arange(12).reshape(3, 4)

arr[1, 2]       # 第二行第三列
arr[:, 1]       # 所有行，第二列
arr[0:2, 1:3]   # 前两行，第二到三列
arr[[0, 2]]     # 取第0行和第2行（花式索引）
```

### 2.4 广播（Broadcasting）—— 深度学习中最容易踩的坑

不同形状的数组做运算时，NumPy 会自动扩展维度。规则：**从末尾维度往前比，维度相等或其中一个为1才兼容**。

```python
# (3, 4) + (4,) —— 可以，末尾维度都是4
a = np.ones((3, 4))
b = np.array([1, 2, 3, 4])
print((a + b).shape)  # (3, 4)

# (3, 4) + (3, 1) —— 可以，(3,1)在第二维广播到4
c = np.array([[1], [2], [3]])
print((a + c).shape)  # (3, 4)
```

### 2.5 常用运算

```python
a = np.random.randn(3, 4)

a.sum()          # 所有元素和
a.sum(axis=0)    # 沿第0维（行间）求和 → shape (4,)
a.sum(axis=1)    # 沿第1维（列间）求和 → shape (3,)
a.mean()         # 均值
a.std()          # 标准差
a.max() / a.min()
a.argmax()       # 最大值的索引（展平后）
a.T              # 转置
np.dot(a, b)     # 矩阵乘法 -- 或 a @ b
```

### 2.6 变形与拼接

```python
a = np.arange(6)

a.reshape(2, 3)           # 变形
a.reshape(-1, 1)           # -1 = "自动算", 变成列向量 (6, 1)
np.expand_dims(a, axis=0)  # (6,) → (1, 6)
np.squeeze(a)              # 去掉大小为1的维度

np.concatenate([a, b], axis=0)  # 拼接
np.stack([a, b], axis=0)        # 堆叠（新增维度）
```

### 2.7 布尔索引

```python
arr = np.array([1, 5, 2, 8, 3])
arr[arr > 3]              # array([5, 8])，取满足条件的元素
(arr > 3).sum()           # 2，满足条件的个数
```

---

## 三、PyTorch 快速过渡

> 前置知识阶段只需要知道 tensor 是什么、怎么创建和运算。d2l 第二章会系统讲。

```python
import torch

# NumPy 风格创建
x = torch.arange(12, dtype=torch.float32).reshape(3, 4)
y = torch.randn(3, 4)
z = torch.zeros_like(x)

# 运算和 NumPy 一模一样
x + y, x * y, x @ y.T
x.sum(), x.mean(dim=0)    # dim = axis

# 和 NumPy 互转
numpy_arr = x.numpy()
torch_tensor = torch.from_numpy(numpy_arr)

# GPU（如果有）
if torch.cuda.is_available():
    x = x.to('cuda')
```

---

## 四、数学基础（够用即可，不求证明）

### 4.1 线性代数

以下概念 d2l 里反复出现，理解"是什么"和"怎么算"即可：

| 概念 | 含义 | 形状/维度 |
|------|------|-----------|
| 标量 | 单个数字 | () |
| 向量 | 一列数 | (n,) |
| 矩阵 | 二维数组 | (m, n) |
| 张量 | 三维及以上 | (c, h, w) |

**点积**（两个向量的对应位置乘起来再求和）：
```python
x = np.array([1, 2, 3])
y = np.array([4, 5, 6])
np.dot(x, y)   # 1*4 + 2*5 + 3*6 = 32
```

**矩阵-向量乘法**（权重矩阵 × 输入 = 输出，全连接层的本质）：
```
(3×4) @ (4×1) → (3×1)
# 3个样本，每个4个特征 → 3个输出值
```

**矩阵乘法**的形状规则：`(m, n) @ (n, p) → (m, p)`，中间维度必须相等。

**范数**（用来做正则化、梯度裁剪）：
```python
np.linalg.norm(x, ord=2)   # L2 范数（欧氏距离）
np.abs(x).sum()             # L1 范数
```

### 4.2 微积分

**导数**：函数在某点的变化率。d2l 里你不需要手算导数，只需理解：

- 梯度 = 偏导数的向量，指向函数增长最快的方向
- **梯度下降**：往负梯度方向走，函数值下降。`w = w - lr * gradient`
- **链式法则**：复合函数求导。反向传播的数学基础。
- **自动求导**：PyTorch 的 `x.backward()` 帮你自动算，不需要手推公式

关键代码（理解即可，课程会展开）：
```python
x = torch.tensor(2.0, requires_grad=True)
y = x ** 2
y.backward()        # 自动算 dy/dx
print(x.grad)       # tensor(4.0)，即 2*x = 4
```

### 4.3 概率论

| 概念 | 在深度学习中的用途 |
|------|-------------------|
| 随机变量 | 模型输出概率分布的基础 |
| 期望 | 损失函数的平均值 |
| 方差/标准差 | 数据归一化（BatchNorm 的核心） |
| 条件概率 | 分类模型输出的本质 P(label|input) |
| 最大似然估计 | 很多损失函数（如交叉熵）的推导源头 |
| 交叉熵 | 分类任务最常用的损失函数 |

---

## 五、常用 Python 库速查

d2l 里会频繁用到这些，提前熟悉即可，不需要精通：

### `os` / `pathlib`
```python
import os
os.path.join('data', 'cifar10')      # 拼接路径
os.path.exists('file.txt')            # 判断文件是否存在
os.makedirs('output', exist_ok=True)  # 创建目录
```

### `collections`
```python
from collections import OrderedDict, defaultdict
# OrderedDict: 保证插入顺序的字典（d2l 中保存模型层时用到）
net = OrderedDict([('linear', nn.Linear(10, 5)), ('relu', nn.ReLU())])
```

### `matplotlib`（画图用）
```python
import matplotlib.pyplot as plt
plt.plot([1, 2, 3], [4, 5, 6])
plt.xlabel('epoch')
plt.ylabel('loss')
plt.show()
```

### `time`
```python
import time
start = time.time()
# ... 训练代码 ...
print(f'耗时: {time.time() - start:.2f}s')
```

---

## 六、课程各章会用到的前置知识速查

| 章节 | 需要的 Python/工具 | 需要的数学 |
|------|-------------------|-----------|
| 2. 预备知识 | tensor 创建/运算、自动求导 | 线性代数、微积分、概率论 |
| 3. 线性神经网络 | `nn.Linear`, `DataLoader` | 矩阵乘法、梯度下降、均方误差 |
| 4. 多层感知机 | `nn.Sequential`, 激活函数 | 非线性变换、链式法则 |
| 5. 深度学习计算 | 自定义层、参数管理 | — |
| 6. 卷积神经网络 | tensor 维度变换、`nn.Conv2d` | 卷积运算 |
| 7. 现代 CNN | `nn.BatchNorm2d`, `nn.Dropout` | 批量归一化原理 |
| 8. 循环神经网络 | `nn.RNN`, 序列处理 | 隐状态、BPTT |
| 9. 现代 RNN | `nn.LSTM`, `nn.GRU` | 门控机制 |
| 10. 注意力机制 | `nn.MultiheadAttention` | softmax、加权和 |
| 11. 优化算法 | SGD, Adam, 学习率调度 | 动量、自适应学习率 |
| 12-14. CV/NLP/GAN | 综合应用 | 综合应用 |

---

## 七、学习顺序建议

1. **先过 Python 核心**（第一节）—— 确保列表推导、切片、zip、lambda、生成器不卡手
2. **NumPy 实操**（第二节）—— 在 Jupyter 里把所有代码敲一遍，特别是广播
3. **PyTorch 过渡**（第三节）—— 感受到和 NumPy 的相似性
4. **数学概念扫盲**（第四节）—— 不要求证明，知道你会在哪里遇到它们
5. **开始 d2l 第一章**—— 用上面的前置知识跟李沐的 notebook，边学边查

---

## 八、常见坑

1. **`(3,)` vs `(3, 1)`**：一维数组和列向量不一样，广播行为不同。不确定时用 `.reshape(-1, 1)` 明确。
2. **`np.random.randn` vs `np.random.rand`**：前者是标准正态，后者是 [0, 1) 均匀分布。
3. **`x.numpy()` 需要 tensor 在 CPU 上**：GPU tensor 要先用 `.cpu()`。
4. **`with torch.no_grad():`**：推理/评估时记得关掉梯度计算，否则会爆显存。
5. **`model.train()` vs `model.eval()`**：影响 Dropout 和 BatchNorm 行为，推理前必须切 eval 模式。
