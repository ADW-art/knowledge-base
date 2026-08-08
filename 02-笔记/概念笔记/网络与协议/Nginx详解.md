---
created: 2026-08-08
updated: 2026-08-08
type: concept
tags: [cs, network, server, devops, web]
aliases: [Nginx, 反向代理, 负载均衡, Web服务器]
---

# Nginx 详解

> **一句话**: Nginx 是一个高性能的 HTTP 服务器 + 反向代理 + 邮件代理，用事件驱动架构在极少内存下处理海量并发连接。

## 核心问题：Nginx 解决什么？

```
互联网早期：一个请求 = 一个进程/线程
    1000 个并发 → 1000 个进程 → 内存爆了 (C10K 问题)

Nginx 的答案：一个 Master 进程 + 少量 Worker 进程
    10000 个并发 → 几个 Worker → 内存几乎不变
```

它的核心场景就三个：

1. **静态文件服务器** — 直接返回 HTML/CSS/JS/图片，比任何后端都快
2. **反向代理** — 挡在你真正的应用服务器（Node/FastAPI/Go）前面，接管客户端连接
3. **负载均衡** — 把请求分发给多台后端服务器

## 核心架构：事件驱动 + 异步非阻塞

```
┌─────────────────────────────────────────┐
│              Master 进程                  │
│  读取配置、管理 Worker、处理信号            │
├──────────┬──────────┬───────────────────┤
│ Worker 1 │ Worker 2 │ Worker N ...      │
│ 事件循环  │ 事件循环  │ 事件循环            │
│ epoll    │ epoll    │ epoll              │
└──────────┴──────────┴───────────────────┘
       ↓         ↓         ↓
   几万个连接全被同一批 Worker 处理
   不阻塞，不在连接上浪费线程
```

**关键机制**（和传统 Apache 的对比）：

| | Apache (prefork) | Nginx |
|------|-----------------|-------|
| 并发模型 | 一个连接 = 一个进程 | 一个 Worker 处理数万个连接 |
| I/O 模型 | 阻塞 I/O | 非阻塞 I/O + epoll/kqueue |
| 内存 | 每个连接吃内存 | 几乎恒定 |
| 适合场景 | 动态内容为主的旧式网站 | 高并发、静态文件、反向代理 |
| C10K | 做不到 | 轻松 |

底层是 Linux 的 **epoll**（或 BSD 的 kqueue）——操作系统告诉 Nginx "这 10000 个连接里，只有 3 个有数据到了，你去读"，而不是 Nginx 自己轮询 10000 次。

## 四大核心功能

### 1. 反向代理

```
                    公网 IP
客户端 ──→  Nginx (反向代理)  ──→  应用服务器 1 (内网 192.168.1.10:3000)
                                ──→  应用服务器 2 (内网 192.168.1.11:3000)
```

**Nginx 扛的事**：
- 接收客户端慢速连接（移动网络 / 3G），应用服务器只处理"干净的"请求
- SSL/TLS 加密解密（应用服务器不需要处理 HTTPS）
- 压缩响应（gzip/brotli）
- 限流、缓存、日志

```nginx
# 最经典的反向代理配置
server {
    listen 80;
    server_name api.your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;   # 转发给 FastAPI
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;       # 把真实客户端 IP 传过去
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 2. 负载均衡

```nginx
# 定义后端服务器池
upstream backend {
    least_conn;                         # 最少连接数算法
    server 192.168.1.10:8000 weight=3;  # 权重 3
    server 192.168.1.11:8000 weight=1;  # 权重 1
    server 192.168.1.12:8000 backup;    # 备用，前面都挂了才用
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

**负载均衡算法**：
| 算法 | 指令 | 场景 |
|------|------|------|
| 轮询（默认） | 不写就是轮询 | 服务器性能一致 |
| 权重 | `weight=N` | 服务器性能不均 |
| 最少连接 | `least_conn` | 长连接业务 |
| IP 哈希 | `ip_hash` | 需要会话保持 |
| 最快响应 | `fair`（第三方） | 跨机房 |

### 3. 静态文件服务

```nginx
server {
    listen 80;
    server_name www.your-site.com;
    root /var/www/dist;    # Vue/React 打包后的静态文件目录

    # 静态资源缓存 30 天
    location /assets/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # SPA 路由 fallback：所有非文件请求都返回 index.html
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

这就是 Vue 3 / React 生产部署的标准姿势——Nginx serve 前端静态文件 + 反向代理 `/api/` 到 FastAPI/Express。

### 4. SSL/TLS 终止

```nginx
server {
    listen 443 ssl http2;
    server_name www.your-site.com;

    ssl_certificate     /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://127.0.0.1:8000;  # 后端跑 HTTP 就行，不用配证书
    }
}

# HTTP 自动跳 HTTPS
server {
    listen 80;
    server_name www.your-site.com;
    return 301 https://$host$request_uri;
}
```

## 典型部署拓扑

这是最常见的生产环境布局：

```
Internet
    │
    ▼
┌──────────┐
│  Nginx   │  ← 80/443 端口，SSL终止，静态文件，gzip压缩，限流
└────┬─────┘
     │ proxy_pass
     ▼
┌──────────┐
│ 应用服务器 │  ← FastAPI/Express/Go (内网，不暴露端口)
└────┬─────┘
     │
     ▼
┌──────────┐
│  数据库   │  ← PostgreSQL/Redis (内网)
└──────────┘
```

以你的 Vue 3 + FastAPI 为例，Nginx 配置就是：

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SPA 前端
    location / {
        root /var/www/dist;
        try_files $uri $uri/ /index.html;
    }

    # API 反向代理
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

**Vue 前端和 FastAPI 后端对客户端来说就是一个域名**，Nginx 根据 URL 路径做分流。这比 CORS 跨域方案干净得多。

## Nginx vs 其他方案

| | Nginx | Caddy | Traefik | Apache |
|------|-------|-------|---------|--------|
| 自动 HTTPS | 手动配 | **自动 Let's Encrypt** | **自动 Let's Encrypt** | 手动配 |
| 性能 | 极高 | 高 | 高 | 中等 |
| 配置方式 | 静态配置文件 | Caddyfile（极简） | 动态 + Docker 标签 | `.htaccess` + 主配置 |
| 学习曲线 | 中等 | **极低** | 陡（Cloud Native 概念多） | 中等 |
| 适合 | 通用，稳定压倒一切 | 个人项目、快速部署 | K8s/Docker 微服务 | 传统 LAMP |
| 内存占用 | ~5MB 起步 | ~20MB（Go 运行时） | ~30MB | ~10MB/进程 |

**什么时候用 Caddy 代替 Nginx？** 个人项目、不想碰证书配置、单服务器跑几个小服务。

## 常见配置陷阱

```nginx
# ❌ 错误：没有 try_files 的 SPA 配置
location / {
    root /var/www/dist;
    # 刷新 /about 会 404，因为 /about 不是真实文件
}

# ✅ 正确
location / {
    root /var/www/dist;
    try_files $uri $uri/ /index.html;  # 找不到文件就 fallback 到 index.html
}
```

```nginx
# ❌ 错误：反向代理没有传 Host 头
location /api/ {
    proxy_pass http://127.0.0.1:8000;
    # FastAPI 收到的 Host 是 127.0.0.1:8000，不是真实域名
}

# ✅ 正确
location /api/ {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header Host $host;                      # 真实域名
    proxy_set_header X-Real-IP $remote_addr;           # 客户端 IP
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;        # http 还是 https
}
```

## 关联概念
- [[全栈前端框架Next.js Remix Nuxt]] → 全栈框架下的部署拓扑
- [[SSR与服务端渲染原理]] → Nginx 在前端部署中的角色
- [[HTTPS与SSL原理]] → Nginx 做 SSL 终止
- [[反向代理与正向代理的区别]] → Nginx 是最经典的反向代理
- [[MOC-计算机通识]] → 回到计算机通识导航

## 动手实现（Karpathy 式）

```bash
# 从零理解 Nginx 到底做了什么 — 一个极简反向代理
# 这个 Python 脚本就是 Nginx 的核心思想的玩具实现：

# 1. 极简反向代理
import socket, threading

def handle_client(client_sock):
    request = client_sock.recv(4096)
    # 转发给真正的应用服务器
    backend = socket.socket()
    backend.connect(('127.0.0.1', 8000))
    backend.send(request)
    response = backend.recv(65536)
    client_sock.send(response)
    client_sock.close()
    backend.close()

# 2. 单进程 + 非阻塞 → 能处理大量连接
server = socket.socket()
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(('0.0.0.0', 80))
server.listen(128)
# Nginx 用 epoll 实现了真正的事件驱动，这个玩具版用线程模拟
while True:
    client, _ = server.accept()
    threading.Thread(target=handle_client, args=(client,)).start()
# 真正的 Nginx 不创建线程——它用 epoll 在一个线程里轮询所有连接
```

## 笔记成长日志
- 2026-08-08: 创建初稿，覆盖反向代理、负载均衡、静态文件、SSL 四大场景
