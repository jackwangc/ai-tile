# Git Submodule 配置指南

本文档介绍如何配置 Git SSH 密钥、克隆仓库并初始化 Git Submodule。

## 一、初始化 GIT 配置

### 1. 检查是否已配置 SSH KEY

```bash
# 检查 SSH 密钥是否存在
ls -la ~/.ssh/id_ed25519.pub
ls -la ~/.ssh/id_rsa.pub
```

如果已存在 SSH 密钥，可以跳过生成步骤。

### 2. 生成 SSH KEY

```bash
# 生成 ed25519 类型的 SSH 密钥（推荐）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 或者生成 RSA 类型的 SSH 密钥
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

生成过程中会提示输入文件保存位置（默认即可）和密码（可以留空）。

### 3. 查看并复制 SSH 公钥

```bash
# 查看公钥内容
cat ~/.ssh/id_ed25519.pub
# 或
cat ~/.ssh/id_rsa.pub
```

### 4. 在 GitHub 上添加 SSH 密钥

1. 登录 GitHub
2. 进入 Settings -> SSH and GPG keys
3. 点击 "New SSH key"
4. 粘贴刚才复制的公钥内容
5. 保存

### 5. 测试 SSH 连接

```bash
ssh -T git@github.com
```

如果看到 "Hi username! You've successfully authenticated..." 说明配置成功。

## 二、代码下载

### 1. 克隆主仓库

```bash
# 注意换成自己代码仓的地址
git clone git@github.com:tile-ai/tilelang-ascend.git

# 进入项目目录
cd ai-tile
```

## 三、更新全局镜像，规避 submodule 无法下载的问题

由于网络原因，直接从 GitHub 下载 submodule 可能会失败或速度很慢。可以通过配置镜像加速来解决这个问题。

### 1. 配置全局镜像

```bash
# 配置 GitHub 镜像加速
git config --global url."https://ghfast.top/https://github.com/".insteadOf "https://github.com/"
```

### 2. 清理并重新初始化 Submodule

```bash
# 清除所有 submodule 配置和缓存
git submodule deinitra --all

# 删除 submodule 缓存目录
rm -rf .git/modules/3rdparty

# 删除 submodule 工作目录
rm -rf 3rdparty/cutlass 3rdparty/tvm 3rdparty/composable_kernel 3rdparty/catlass 3rdparty/pto-isa 3rdparty/shmem

# 查看 submodule 状态
git submodule status
```

### 3. 递归更新 Submodule

```bash
# 递归初始化并更新所有 submodule
git submodule update --init --recursive
```

### 4. 验证 Submodule 状态

```bash
# 查看 submodule 状态
git submodule status

# 查看 submodule 详细信息
git submodule foreach 'echo $name && git log -1'
```

## 四、还原镜像配置

如果需要恢复原始 GitHub 地址，可以取消镜像配置。

```bash
# 查看当前镜像配置是否生效
git config --global --get url."https://ghfast.top/https://github.com/".insteadOf

# 还原配置（取消镜像）
git config --global --unset url."https://ghfast.top/https://github.com/".insteadOf
```

## 五、常用 Submodule 操作命令

### 查看 submodule 信息

```bash
# 查看 submodule 列表和状态
git submodule

# 查看 submodule 详细信息
git submodule status

# 查看 .gitmodules 配置文件
cat .gitmodules
```

### 更新 submodule

```bash
# 更新所有 submodule 到最新提交
git submodule update --remote

# 更新指定 submodule
git submodule update --remote 3rdparty/cutlass

# 拉取 submodule 的最新代码
git submodule foreach git pull origin main
```

### 切换 submodule 分支

```bash
# 切换到指定 submodule 的特定分支
cd 3rdparty/cutlass
git checkout main
cd ../..
```

### 添加新的 submodule

```bash
# 添加新的 submodule
git submodule add https://github.com/username/repo.git path/to/submodule

# 提交变更
git add .gitmodules path/to/submodule
git commit -m "Add new submodule"
```

### 删除 submodule

```bash
# 删除 submodule（三个步骤）
git submodule deinit path/to/submodule
rm -rf .git/modules/path/to/submodule
git rm -f path/to/submodule
```

## 六、完整安装流程示例

```bash
# 1. 检查/生成 SSH 密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. 复制公钥到 GitHub
cat ~/.ssh/id_ed25519.pub

# 3. 测试 SSH 连接
ssh -T git@github.com

# 4. 克隆主仓库
git clone git@github.com:tile-ai/tilelang-ascend.git
cd ai-tile

# 5. 配置镜像加速
git config --global url."."https://ghfast.top/https://github.com/".insteadOf "https://github.com/"

# 6. 初始化并更新 submodule
git submodule update --init --recursive

# 7. 验证安装
git submodule status
```

## 七、常见问题

### 1. Submodule 更新失败

**问题：** 执行 `git submodule update` 时出现网络错误或下载失败。

**解决方案：**
- 配置镜像加速（参考第三部分）
- 使用 VPN 或代理
- 尝试手动克隆 submodule 仓库

### 2. Submodule 处于分离头指针状态

**问题：** Submodule 显示处于 "detached HEAD" 状态。

**解决方案：**
```bash
# 进入 submodule 目录
cd 3rdparty/cutlass

# 切换到主分支
git checkout main

# 返回主仓库
cd ../..
```

### 3. Submodule 未初始化

**问题：** Submodule 目录为空或不存在。

**解决方案：**
```bash
# 初始化 submodule
git submodule init

# 更新 submodule
git submodule update
```

### 4. 权限错误

**问题：** 无法访问私有仓库的 submodule。

**解决方案：**
- 确保 SSH 密钥已正确配置
- 确保有访问权限
- 检查 GitHub 仓库设置中的 Collaborators 权限