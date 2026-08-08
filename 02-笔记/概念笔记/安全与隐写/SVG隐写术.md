---
created: 2026-07-18
updated: 2026-07-18
type: concept
tags: [security, steganography, svg, web]
aliases: [SVG隐写术, SVG Steganography, XML隐写]
---

# SVG 隐写术

> **一句话**: 利用 SVG 文件的 XML 结构和渲染特性，将数据藏在肉眼看不见的地方。

---

## 1. SVG 为什么适合藏东西？

SVG（可缩放矢量图形）本质上是 **XML 文本文件**。跟图片文件（PNG/JPEG）相比，SVG 有两个巨大优势：

| 特性 | PNG/JPEG | SVG |
|------|---------|-----|
| 数据格式 | 二进制（bit-level） | **纯文本 XML** |
| 可读性 | 不可读 | **人类可读** |
| 藏匿点 | 像素 LSB | **标签、属性、注释、结构** |
| 检测难度 | 统计检测 | **看起来像正常 SVG 代码** |

因为 SVG 是文本，你可以把信息藏在 **代码结构** 里，而不是像素里——这更难被检测到。

---

## 2. 藏匿技术（由浅入深）

### 技术 1：注释隐藏（最简单）

```xml
<svg xmlns="...">
  <!-- 秘密信息 -->
  <rect width="100" height="100" fill="blue"/>
</svg>
```

### 技术 2：隐藏元素

在视口外放置元素或设置透明度为 0：

```xml
<text x="0" y="500" font-size="12" opacity="0">隐藏消息</text>
<circle cx="50" cy="50" r="10" fill-opacity="0" data-secret="SECRET"/>
```

### 技术 3：自定义属性（data-*）

```xml
<rect fill="blue" data-a="72" data-b="69" data-c="76"/>
```

每个 data-* 存一个 ASCII 码。

### 技术 4：浮点数精度隐写

```xml
<!-- 正常 -->
<path d="M 10.0000 10.0000"/>
<!-- 隐写（小数位携带信息） -->
<path d="M 10.0001 10.0000"/>
```

### 技术 5：颜色 LSB 隐写

```xml
<rect fill="#FF0001"/>  <!-- 最后一位携带 1 bit -->
```

## 3. 完整示例

```python
# 藏入
svg = '<svg><rect fill="#0000{:02X}"/></svg>'.format(ord('A'))
# 每个字符的 ASCII 存在蓝色通道

# 取出
blue = int(re.search(r'fill="#([A-F0-9]+)"', svg).group(1)[-2:], 16)
print(chr(blue))  # 'A'
```

## 4. 在红队中的应用

| 场景 | 说明 |
|------|------|
| C2 通信 | 指令藏在 SVG 中绕过流量检测 |
| 数据外传 | 藏数据到公共图床 |
| 钓鱼 | SVG 可携带 JS + 隐写数据 |

## 5. 检测方法

- 查看源代码（注释、data-*、隐藏元素）
- 检查 opacity=0 或超大坐标
- 分析颜色低字节异常
- 对比标准 SVG 属性集合

## 动手实践（Karpathy 式）

```python
# 从零写一个 SVG 隐写工具：
# 1. 读取 SVG
# 2. 将消息编码到浮点数小数位
# 3. 验证人眼看不出区别
# 4. 写提取器
```
