# VMware 上配置 d2l 环境 · 完整操作手册

> 从 Ubuntu 安装到跑通第一个 notebook，每一步都可复制粘贴。

---

## 一、安装 Ubuntu

1. VMware 里点击"开启此虚拟机"
2. 选择语言：**English**（避免中文路径编码问题）
3. 键盘布局：默认 English (US)，直接 Continue
4. 安装类型选 **Normal installation**，勾上 "Download updates while installing"
5. 磁盘分区选 **Erase disk and install Ubuntu**（放心，只擦虚拟磁盘，不影响宿主机）
6. 时区：在搜索框输入 **Shanghai**
7. 填写用户名和密码（**用英文**，不要中文），建议：
   - Your name: `d2l`
   - Computer name: `ubuntu-d2l`
   - Username: `d2l`
   - Password: 设个简单的，学习环境不讲究安全性
8. 等待安装完成（约 10-15 分钟），点击 **Restart Now**

---

## 二、首次登录后的配置

```bash
# 1. 更新系统
sudo apt update && sudo apt upgrade -y

# 2. 安装 VMware Tools（拖拽文件、自适应分辨率）
sudo apt install -y open-vm-tools open-vm-tools-desktop

# 3. 安装必要工具
sudo apt install -y wget git curl build-essential

# 4. 重启让 VMware Tools 生效
sudo reboot
```

重启后验证：试试能不能把 Windows 上的文件拖进 Ubuntu 桌面，或者调整 VMware 窗口大小看分辨率是否自适应。

---

## 三、安装 Miniconda

```bash
# 下载
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# 运行安装脚本
bash Miniconda3-latest-Linux-x86_64.sh
```

安装过程中：
- 按 `Enter` 往下翻 license（一直按）
- 出现 `Do you accept the license terms?` 输入 **yes**
- 安装路径直接按 `Enter`（用默认的 `/home/d2l/miniconda3`）
- 最后问 `Do you wish the shell to be initialized by conda?` 输入 **yes**

**关掉终端，重新打开**，输入：

```bash
conda --version
```

显示版本号（如 `conda 24.x.x`）说明安装成功。

---

## 四、创建 d2l 专属 Python 环境

```bash
# 创建名为 d2l 的环境，Python 3.10
conda create -n d2l python=3.10 -y

# 激活环境
conda activate d2l

# 每次开终端都要先激活，验证当前环境
which python
# 应输出：/home/d2l/miniconda3/envs/d2l/bin/python
```

> 以后每次打开终端干活前，先 `conda activate d2l`。

---

## 五、安装 PyTorch（CPU 版）

```bash
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
```

验证：

```bash
python -c "import torch; print(torch.__version__); x = torch.ones(3,3); print(x)"
```

如果能打印出 3×3 的全 1 矩阵，PyTorch 就装好了。

---

## 六、安装课程依赖

```bash
# d2l 核心包
pip install d2l==1.0.3

# Jupyter
pip install jupyter notebook

# 其他依赖
pip install matplotlib pandas
```

---

## 七、下载课程代码并启动

```bash
# 克隆中文版仓库
git clone https://github.com/d2l-ai/d2l-zh.git
cd d2l-zh

# 启动 Jupyter，允许外部访问
jupyter notebook --ip=0.0.0.0 --no-browser
```

终端会输出类似：

```
http://127.0.0.1:8888/?token=abc123def456...
```

---

## 八、在 Windows 浏览器里打开

1. 复制终端里那个 `http://127.0.0.1:8888/?token=...` 的完整 URL
2. 在宿主机（Windows）浏览器里粘贴打开
3. 页面加载后能看到 `d2l-zh` 目录下的所有 `.ipynb` 文件
4. 点开 `chapter_preliminaries/ndarray.ipynb`，按 `Shift+Enter` 逐格运行

> 能跑通说明环境完全 OK。

---

## 九、以后怎么继续

每次要学习时：

```bash
# 1. 打开 VMware，启动 Ubuntu 虚拟机
# 2. 登录 Ubuntu，打开终端
# 3. 激活环境
conda activate d2l

# 4. 进入课程目录
cd ~/d2l-zh

# 5. 启动 Jupyter
jupyter notebook --ip=0.0.0.0 --no-browser

# 6. 把 URL 复制到 Windows 浏览器
```

---

## 十、共享文件夹（让虚拟机和宿主机读写同一份文件）

如果你想把笔记直接存到 `E:\code\知识库`：

1. VMware 菜单 → **虚拟机** → **设置**
2. **选项** 标签 → **共享文件夹**
3. 文件夹共享选 **总是启用**
4. 点击 **添加** → 浏览选择 `E:\code\知识库` → 名称填 `kb`
5. 在 Ubuntu 里访问：

```bash
# 挂载共享文件夹
sudo mkdir -p /mnt/kb
sudo mount -t fuse.vmhgfs-fuse .host:/kb /mnt/kb -o allow_other

# 查看内容
ls /mnt/kb
```

> 这样你在 Windows 里用 Obsidian 编辑笔记，Ubuntu 里用 Jupyter 跑代码，都能读写同一份文件。

---

## 常见问题

| 问题 | 解决 |
|------|------|
| `conda: command not found` | 装完 Miniconda 没重启终端，关掉重开 |
| Jupyter 地址打不开 | 确认虚拟机网络是 NAT 模式，`ping 127.0.0.1` 能通 |
| `ModuleNotFoundError: No module named 'd2l'` | `conda activate d2l` 没激活环境 |
| 共享文件夹看不到内容 | `sudo mount -t fuse.vmhgfs-fuse .host:/kb /mnt/kb -o allow_other` |
| 拖拽文件失灵 | 装完 open-vm-tools 后没重启，`sudo reboot` 一下 |
| PyTorch 安装报错找不到 whl | 用了错误的 `--index-url`，检查拼写 |


---

## 关联笔记

- [[MOC-AI与智能体|AI 与智能体 MOC]]
- [[python前置知识|Python 前置知识]]
