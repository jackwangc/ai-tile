# TileLang 一键安装脚本

本脚本提供 TileLang 项目的自动化安装，包括 SSH 密钥配置检查、代码克隆、Submodule 镜像配置和安装脚本执行。

## 功能特性

- ✅ 自动检查和配置 SSH 密钥
- ✅ 克隆 TileLang 仓库
- ✅ 配置 GitHub 镜像加速 Submodule 下载
- ✅ 自动初始化和更新 Submodule
- ✅ 执行 TileLang 安装脚本
- ✅ 支持自定义仓库地址

## 使用方法

### 基本用法

```bash
bash ai-tile/install_tilelang.sh
```

### 高级用法

```bash
# 指定自定义仓库地址
bash ai-tile/install_tilelang.sh --repo git@github.com:your-username/your-repo.git
```

### 查看帮助

```bash
bash ai-tile/install_tilelang.sh --help
```

## 安装流程

脚本执行以下步骤：

### 1. 系统检查

- 检查操作系统是否为 Linux
- 不支持 macOS 或其他操作系统

### 2. SSH 密钥检查

- 检查是否已存在 SSH 密钥（`~/.ssh/id_ed25519.pub` 或 `~/.ssh/id_rsa.pub`）
- 如果不存在，提示用户生成新的 SSH 密钥
- 显示公钥内容，提示用户添加到 GitHub
- 测试 SSH 连接到 GitHub

### 3. 克隆仓库

- 检查目标目录是否已存在
- 如果存在，询问是否重新克隆
- 克隆指定的仓库（默认：`git@github.com:tile-ai/tilelang-ascend.git`）

### 4. 配置镜像

- 配置全局 GitHub 镜像：`https://ghfast.top/https://github.com/`
- 加速 Submodule 下载速度

### 5. 更新 Submodule

- 清理现有的 Submodule 缓存和目录
- 递归初始化和更新所有 Submodule
- 显示 Submodule 状态

### 6. 执行安装脚本

- 执行 `tilelang-ascend/install_ascend.sh` 脚本

### 7. 清理

- 移除镜像配置，恢复原始 GitHub 地址

## 命令行选项

| 选项 | 说明 |
|------|------|
| `--repo URL` | 指定仓库地址（默认：`git@github.com:tile-ai/tilelang-ascend.git`） |
| `--help`, `-h` | 显示帮助信息 |

## 前置要求

### 系统要求

- Linux 操作系统（不支持 macOS）
- Git 已安装
- Python 3.10 或更高版本
- Bash shell

### 必需工具

```bash
# 检查 Git
git --version

# 检查 Python
python3 --version

# 检查 Bash
bash --version
```

### GitHub 账户

- GitHub 账户
- 仓库访问权限
- SSH 密钥已添加到 GitHub 账户

## 手动配置 SSH 密钥

如果脚本检测到 SSH 密钥不存在，会提示您生成新的密钥。您也可以手动配置：

### 1. 生成 SSH 密钥

```bash
# 生成 ed25519 类型的 SSH 密钥（推荐）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 或生成 RSA 类型的 SSH 密钥
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### 2. 查看公钥

```bash
cat ~/.ssh/id_ed25519.pub
# 或
cat ~/.ssh/id_rsa.pub
```

### 3. 添加到 GitHub

1. 登录 GitHub
2. 进入 Settings -> SSH and GPG keys
3. 点击 "New SSH key"
4. 粘贴公钥内容
5. 保存

### 4. 测试连接

```bash
ssh -T git@github.com
```

## 故障排除

### SSH 密钥问题

**问题：** 提示 SSH 密钥不存在或连接失败

**解决方案：**
- 确保已生成 SSH 密钥
- 确保公钥已添加到 GitHub 账户
- 检查 SSH 密钥权限：`chmod 600 ~/.ssh/id_ed25519`

### Submodule 下载失败

**问题：** Submodule 更新失败或速度很慢

**解决方案：**
- 脚本会自动配置镜像加速
- 如果仍然失败，尝试手动配置代理
- 检查网络连接

### 权限问题

**问题：** 脚本执行权限不足

**解决方案：**
```bash
# 赋予脚本执行权限
chmod +x ai-tile/install_tilelang.sh

# 直接执行
./ai-tile/install_tilelang.sh
```

## 验证安装

安装完成后，验证 TileLang 是否正确安装：

```bash
# 进入项目目录
cd ai-tile

# 检查 Submodule 状态
git submodule status

# 检查 Python 包
python3 -c "import tilelang; print(tilelang.__version__)"

# 检查构建产物
ls -la build/
```

## 卸载

如需卸载 TileLang：

```bash
# 删除项目目录
rm -rf ai-tile

# 卸载 Python 包
pip uninstall tilelang -y

# 清理 Submodule 缓存
rm -rf ~/.git/modules
```

## 技术支持

如遇到问题，请：

1. 检查本文档的故障排除部分
2. 查看脚本输出日志
3. 提交 Issue 到项目仓库

## 许可证

本脚本遵循 MIT 许可证。

## 更新日志

### v1.0.0 (2024-02-26)

- 初始版本发布
- 支持 SSH 密钥检查和配置
- 支持仓库克隆
- 支持 Submodule 镜像配置
- 支持安装脚本执行
- 支持自定义选项
