如果之后服务停了，在 PowerShell 里到 `E:\code\MizukiBot` 目录执行：

```powershell
$env:NODE_ENV = "development"
node node_modules/koishi/bin.js start -r esbuild-register -r yml-register
```

停止服务可以执行：
```powershell
Stop-Process -Id 8208,2824
```

这个 PID 只在当前会话有效，以后如果变了，在任务管理器里结束 node 进程即可。
