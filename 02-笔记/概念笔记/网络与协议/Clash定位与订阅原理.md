---
created: 2026-07-19
updated: 2026-07-19
type: concept
tags: [network, proxy, clash, subscription]
aliases: [Clash定位, 机场订阅, 代理协议, mihomo]
---

# Clash 的定位、订阅的原理、连接的全貌

---

## 1. Clash 到底是什么

Clash 是一个**代理规则引擎**，不是一个 VPN。

| | VPN | Clash |
|--|-----|-------|
| 做了什么 | 把整个设备的流量都加密转到另一台机器 | 根据规则决定每条连接走代理还是直连 |
| 灵活性 | 全有或全无 | 可以 github.com 走代理，baidu.com 直连 |
| 协议 | WireGuard / OpenVPN / IPSec | vmess / shadowsocks / trojan / hysteria2 |
| 配置方式 | 简单 | 复杂（规则多） |

Clash 的定位是一个**中间人**——它不生产代理，也不消费代理，它只做调度：

```
你的请求 → Clash → 判断规则 → 选哪个出口
                                ├─ 直连（国内网站）
                                ├─ 拒绝（广告/追踪）
                                └─ 走代理服务器（被墙的网站）
```

---

## 2. Clash 是通用的吗

**核心是通用的，客户端不是。**

```
Clash 核心（mihomo / Clash Meta）
    └── 标准化的配置文件格式（YAML）
             ├── Clash for Windows  ← Windows 客户端
             ├── ClashX / ClashX Pro ← Mac 客户端
             ├── Clash Party         ← Windows 客户端
             ├── FlClash             ← Windows 客户端
             ├── Clash Verge         ← 跨平台
             ├── Clash Nyanpasu      ← 跨平台
             └── OpenClash           ← 路由器 OpenWRT 插件
```

**所有 Clash 客户端读的都是同一种 YAML 配置文件格式。** 所以：

- 机场给你的订阅链接 → 返回一个 YAML 文件
- 这个 YAML 文件**任何 Clash 客户端都能用**
- 你从 FlClash 切到 Clash Party，同一个订阅链接直接导入就行了

这是 Clash 生态最大的优势——**配置文件标准化，不必绑定某个客户端。**

---

## 3. 机场订阅到底是什么

### 本质上是一个 URL

```
https://xn--4gq171p.com/api/v1/client/subscribe?token=xxxxxxxxxxxxx
```

这个 URL 背后：

```
机场服务器
    ↓ 你请求这个链接
返回一个 YAML 文本文件
    ↓ Clash 解析
得到几十个代理节点
    ↓ 显示在界面上
你可以选一个用
```

### YAML 订阅文件长什么样

```yaml
proxies:
  - name: 香港-01
    type: vmess
    server: hk01.example.com
    port: 443
    uuid: xxxx-xxxx-xxxx
    cipher: auto
    tls: true

  - name: 日本-01
    type: hysteria2
    server: jp01.example.com
    port: 8443
    password: xxxx

  - name: 新加坡-01
    type: trojan
    server: sg01.example.com
    port: 443
    password: xxxx
    sni: sg01.example.com

proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - 香港-01
      - 日本-01
      - 新加坡-01
```

### 机场怎么盈利

机场 = 一群人合租一台境外服务器的商业模式：

```
你（¥10/月） ─┐
你朋友（¥10/月）├── 机场主 → 租一台境外服务器（¥100/月）
其他人（¥10/月）┘              ↑
                          赚你 ¥10 × 50人 = ¥500 - ¥100 = ¥400
```

好的机场：服务器负载合理，节点稳定
差的机场：一台服务器塞几百人，全卡死

---

## 4. 是怎么连通上的

### 完整链路

```
你的浏览器输入 https://github.com
       ↓
1. 操作系统查系统代理设置 → 127.0.0.1:7890
       ↓
2. Clash (mihomo) 在 7890 端口接到请求
       ↓
3. Clash 查规则表：
   "github.com" → 匹配 "PROXY" 组 → 走代理
       ↓
4. 从 PROXY 组选当前节点 → "香港-01"
       ↓
5. 用"香港-01"的配置（server/hk01.example.com, port=443, type=trojan）
       ↓
6. Clash 向 hk01.example.com:443 发起 TCP 连接
       ↓
7. 进行 trojan 协议握手（加密、认证）
       ↓
8. 连接建立后，Clash 告诉服务器："帮我请求 https://github.com"
       ↓
9. 服务器收到指令，向 github.com 发起请求
       ↓
10. GitHub 返回数据给服务器
       ↓
11. 服务器加密数据，传回给你本地的 Clash
       ↓
12. Clash 解密，把数据返回给你的浏览器
       ↓
13. 浏览器渲染出 GitHub 页面
```

### 协议加密的作用

```
vmess:        每个包都加密，看起来像随机字节
shadowsocks:  流量加密 + 混淆，看起来像普通流量
trojan:       伪装成 HTTPS 流量（跟正常网站访问一样）
hysteria2:    基于 UDP，专门优化弱网环境
anytls:       伪装成 TLS 握手，难以识别
```

这层加密让 GFW 无法识别你在访问什么网站，只能看到"有人往香港服务器发了加密数据"。

---

## 5. 那上次的机场为什么挂了

上次的机场问题出在这里：

```text
44 个节点名字
    ↓
实际只有 6 台服务器
    ↓
5 台都挂了/被墙
    ↓
只剩 1 台 103.181.165.123 在撑
```

名字多 ≠ 节点多。你换的新机场虽然节点少（我看到的只有14个左右），但服务器稳定，0.93s 就能打开 GitHub。

---

## 关联笔记
- [[Clash Party是什么]] ← 你的代理客户端
- [[GitHub Actions 入门]] ← GitHub 的 CI/CD 系统
