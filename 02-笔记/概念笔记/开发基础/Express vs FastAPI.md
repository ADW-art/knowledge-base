---
created: 2026-08-08
updated: 2026-08-08
type: concept
tags: [cs, backend, web, python, nodejs]
aliases: [Express vs FastAPI, 后端框架对比, Node.js后端, Python后端]
---

# Express vs FastAPI：两大后端框架深度对比

> **一句话**: Express 是无约束的 Node.js 极简框架（"给你积木，自己搭"），FastAPI 是 Python 的声明式高性能框架（"按我说的写，我替你校验和生成文档"）。两者代表了两种完全不同的后端设计哲学。

## 先搞清楚各自是什么

### Express — Node.js 的 HTTP 工具箱

Express 是 Node.js 生态里最老牌、装机量最大的 Web 框架。它本质上就是 Node.js 原生 `http` 模块的薄封装：

```javascript
// Node.js 原生写法
const http = require('http')
http.createServer((req, res) => {
  if (req.url === '/api/hello' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ msg: 'hello' }))
  } else {
    res.writeHead(404)
    res.end()
  }
}).listen(3000)
```

```javascript
// Express 写法 — 路由匹配帮你做了，别的没多管
const app = require('express')()
app.get('/api/hello', (req, res) => res.json({ msg: 'hello' }))
app.listen(3000)
```

Express 给你的只有三样东西：**路由匹配**、**中间件机制**、**req/res 包装**。剩下的一切（参数校验、ORM、API 文档、项目结构）全部你自己决定。

### FastAPI — Python 的声明式 API 框架

FastAPI 是 Python 3.8+ 的现代 Web 框架，核心卖点是用 Pydantic 做类型声明、用 Starlette 做异步高性能、自动生成 OpenAPI 文档。

```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class HelloResponse(BaseModel):
    msg: str

@app.get("/api/hello", response_model=HelloResponse)
async def hello():
    return {"msg": "hello"}
```

FastAPI 给你的远不止路由：**自动参数校验**、**自动生成 Swagger 文档**、**依赖注入系统**、**后台任务**、**WebSocket 原生支持**、**Pydantic 序列化/反序列化**。

---

## 核心哲学差异

| 维度 | Express | FastAPI |
|------|---------|---------|
| 设计哲学 | **极简主义** — 只给路由和中间件，剩下你定 | **声明式** — 类型声明驱动，框架替你干脏活 |
| 参数校验 | 无。你手动从 `req.body` 取，手动检查 | 自动。Pydantic Model 声明即校验 |
| API 文档 | 无。需额外装 swagger-jsdoc | **自动生成** `/docs` 交互式 Swagger |
| 类型安全 | TypeScript 可选，但运行时无校验 | Pydantic 运行时强制校验 |
| 项目结构 | 完全自由（容易写出单文件巨石） | 框架引导你分层（routers/services/models/schemas） |
| 依赖注入 | 无内置 | `Depends()` 一等公民 |
| 异步模型 | `async/await` 手动写 | ASGI + `async def` 原生支持 |
| 生态优势 | npm 包数量最大 | Python 数据科学 / ML / 量化生态 |

**核心区别一句话**：Express 给你最少的 API 和最⼤的自由；FastAPI 给你更多的约束，但每个约束都带来自动化的收益。

---

## 同一个 API 的两种写法

场景：一个产品查询接口，接收查询参数，访问数据库，返回结构化 JSON。

### Express 写法

```typescript
// server.ts — 所有东西在一个文件里自给自足
import express from "express"

const app = express()
app.use(express.json())

// 参数 — 手动取，手动验证
app.get("/api/products", async (req, res) => {
  try {
    const category = req.query.category as string | undefined
    const maxPrice = req.query.maxPrice ? Number(req.query.maxPrice) : undefined

    // 手动校验 — 忘了？那就等着运行时炸
    if (maxPrice && isNaN(maxPrice)) {
      return res.status(400).json({ error: "maxPrice 必须是数字" })
    }

    // 业务逻辑
    const products = await db.query(
      "SELECT * FROM products WHERE category = $1 AND price <= $2",
      [category, maxPrice]
    )

    // 手动序列化 — 字段名拼错？TypeScript 能救，但得你手动写 interface
    return res.json(products)
  } catch (err) {
    res.status(500).json({ error: "服务器内部错误" })
  }
})

app.listen(3000)
```

**Express 的问题在这里暴露无遗**：
- `req.query.category` 类型是 `string | undefined`，没校验就传给 SQL，可能炸
- 错误处理全靠 try-catch
- 没有 API 文档，别人不知道这个接口接受什么参数
- 返回什么结构全靠自觉

### FastAPI 写法

```python
# schemas.py — 请求和响应的形状
from pydantic import BaseModel

class ProductQuery(BaseModel):
    category: str | None = None
    max_price: float | None = None

class ProductResponse(BaseModel):
    id: int
    name: str
    price: float
    category: str

# routers/products.py — 路由层
from fastapi import APIRouter, Query

router = APIRouter(prefix="/api/products", tags=["产品"])

@router.get("/", response_model=list[ProductResponse])
async def list_products(query: ProductQuery = Query()):
    # query 已经被 Pydantic 自动校验过了
    # 如果前端传了 max_price=abc，FastAPI 会自动返回 422 错误
    products = await db.fetch_products(query.category, query.max_price)
    return products

# main.py — 应用入口
from fastapi import FastAPI
app = FastAPI(title="我的 API", version="1.0")
app.include_router(router)
```

**FastAPI 自动做的事**：
1. `max_price` 如果前端传了 `"abc"`，自动返回 422 + 详细错误信息
2. `/docs` 自动生成交互式 API 文档，前端/同事可以直接在浏览器里测试
3. `list[ProductResponse]` 保证了返回结构，不会漏字段
4. 你忘了写 500 错误处理？FastAPI 有默认异常处理器

---

## 项目结构：自由 vs 约束

### Express 典型项目（完全自定义）

```
my-express-app/
├── server.ts            # 什么都可能在这里
├── routes/
│   ├── products.ts      # 路由处理函数
│   └── users.ts
├── middleware/
│   └── auth.ts          # 自己写的中间件
├── models/              # 可能是 ORM 模型，也可能只是 interface
├── package.json
└── tsconfig.json
```

Express 项目长什么样**完全取决于写的人**。可以像智期那样一个 `server.ts` 搞定，也可以拆分几十个文件。没有标准，接手别人的 Express 项目得先搞清楚他的组织逻辑。

### FastAPI 典型项目（社区共识）

```
my-fastapi-app/
├── main.py              # FastAPI app 实例 + 路由注册 + 启动事件
├── config.py            # 配置管理（pydantic-settings）
├── dependencies.py      # 依赖注入（get_db, get_current_user）
├── routers/
│   ├── products.py      # 只负责路由：收请求 → 调 service → 返回
│   └── users.py
├── services/
│   ├── product_service.py  # 业务逻辑层
│   └── user_service.py
├── schemas/
│   ├── product.py       # Pydantic 模型（请求/响应结构）
│   └── user.py
├── models/
│   └── database.py      # SQLAlchemy ORM 模型
├── requirements.txt
└── Dockerfile
```

这个结构不是 FastAPI 强制的，但社区几乎都这么写。接手任何 FastAPI 项目，你都知道去哪里找路由、去哪里找业务逻辑。**框架没有创造这种一致性，但它用类型系统和依赖注入引导你往这个方向走。**

---

## 中间件模型对比

### Express 洋葱模型

```typescript
// 中间件按注册顺序执行，先进入后退出（洋葱）
app.use(async (req, res, next) => {
  console.log("1. 进入")
  await next()
  console.log("1. 退出")
})
app.use(async (req, res, next) => {
  console.log("2. 进入")
  await next()
  console.log("2. 退出")
})
// 输出：1.进入 → 2.进入 → 2.退出 → 1.退出
```

### FastAPI 中间件

```python
# FastAPI 中间件本质是 Starlette 中间件，也是洋葱模型
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start
    response.headers["X-Process-Time"] = str(duration)
    return response
```

两者中间件模型几乎一致，这一层没有优劣之分。

---

## 什么时候用哪个

| 场景 | 选 Express | 选 FastAPI |
|------|-----------|-----------|
| 个人小项目、快速原型 | ✅ 简单直接 | ✅ 简单直接，还自带文档 |
| 团队协作、多人开发 | ⚠️ 需要额外约定规范 | ✅ Pydantic + Swagger 天然协作 |
| 前后端类型共享 | ✅ 前后端都是 TS | ❌ 需手动维护或用 OpenAPI 生成 |
| Python 生态刚需（量化/ML） | ❌ Node.js 做不到 | ✅ **这是决定性因素** |
| 需要 API 文档 | ⚠️ 额外装 swagger-jsdoc | ✅ 零配置自动生成 |
| 高并发 I/O | ✅ 事件循环天然优势 | ✅ ASGI 异步，性能同级 |
| CPU 密集型 | ❌ 单线程阻塞 | ⚠️ 需用 Celery/后台任务 |
| 微服务 / 可观测性 | ⚠️ 手撸或第三方 | ✅ OpenTelemetry 标准集成 |
| 学习成本 | 低（API 就那几个） | 中（Pydantic + Depends 需要适应） |

---

## 关联概念
- [[全栈前端框架Next.js Remix Nuxt]] → 一体化全栈如何替代 Express
- [[Vue 3 vs React 核心差异]] → 前端框架选型
- [[Nginx详解]] → 后端前面的反向代理层
- [[Python 异步编程 async await]] → FastAPI 底层 ASGI 原理
- [[MOC-计算机通识]] → 回到计算机通识导航

## 动手实现（Karpathy 式）

```python
# 从零理解 FastAPI 的核心思想 — 一个极简版实现
# 为什么声明类型就能自动校验和生成文档？原理大概长这样：

import inspect
from typing import get_type_hints

class MiniFastAPI:
    def __init__(self):
        self.routes = []

    def get(self, path: str):
        def decorator(func):
            hints = get_type_hints(func)            # ← 读函数的类型标注
            self.routes.append((path, func, hints))
            return func
        return decorator

    def serve(self, path: str):
        for route_path, func, hints in self.routes:
            if route_path == path:
                # 解析 query string → 用类型标注自动转换和校验
                typed_params = {}
                for name, typ in hints.items():
                    if name == "return": continue
                    raw = "42"  # 模拟从 query string 拿到的原始值
                    typed_params[name] = typ(raw)   # ← float("abc") 这里会炸
                result = func(**typed_params)
                # 用返回类型标注校验
                return_type = hints.get("return")
                print(f"[OpenAPI] GET {path} → {return_type}")  # ← 自动生成文档
                return result

app = MiniFastAPI()

@app.get("/api/double")
def double(x: float) -> float:   # 类型标注就是全部
    return x * 2

# 这个玩具输出了：
# [OpenAPI] GET /api/double → <class 'float'>
# 真正 FastAPI 做的：类型 → JSON Schema → OpenAPI → Swagger UI
```

```typescript
// Express 的极简实现 — 本质上就是路由表 + 中间件链
class MiniExpress {
  private routes: Map<string, Function> = new Map()
  private middlewares: Function[] = []

  get(path: string, handler: Function) {
    this.routes.set(`GET ${path}`, handler)
  }

  use(mw: Function) {
    this.middlewares.push(mw)
  }

  async handle(req: { url: string, method: string }) {
    let idx = 0
    const next = async () => {
      if (idx < this.middlewares.length) {
        await this.middlewares[idx++](req, next)
      }
    }
    await next()  // — 中间件链执行完毕
    const handler = this.routes.get(`${req.method} ${req.url}`)
    return handler ? handler(req) : "404"
  }
}
```

## 笔记成长日志
- 2026-08-08: 创建初稿，覆盖架构哲学、代码对比、项目结构、选型指南
