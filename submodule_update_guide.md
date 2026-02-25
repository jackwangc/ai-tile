# 子模块更新指南

## 问题描述

在无法直接访问 `github.com` 的环境中，执行 `git submodule update --init --recursive` 会失败，出现以下错误：
- `Failed to connect to github.com port 443: Connection timed out`
- `GnuTLS recv error`

## 解决方案

使用国内镜像源替代 GitHub URL。

### 修改的文件

1. `.gitmodules` - 主项目的子模块配置
2. `3rdparty/tvm/.gitmodules` - TVM 的嵌套子模块配置

### 使用的镜像源

| 镜像源 | URL | 适用范围 |
|--------|-----|----------|
| gitclone.com | https://gitclone.com/github.com/{repo} | 大多数 GitHub 仓库 |
| ghfast.top | https://ghfast.top/https://github.com/{repo} | flashinfer, libflash_attn, libbacktrace |
| gitee.com | https://gitee.com/ascend/catlass.git | catlass (已有) |
| gitcode.com | https://gitcode.com/cann/{repo} | pto-isa, shmem (已有) |

## 修改详情

### 主项目 .gitmodules

```ini
[submodule "3rdparty/cutlass"]
    path = 3rdparty/cutlass
    url = https://gitclone.com/github.com/NVIDIA/cutlass

[submodule "3rdparty/tvm"]
    path = 3rdparty/tvm
    url = https://gitclone.com/github.com/TileLang/tvm

[submodule "3rdparty/composable_kernel"]
    path = 3rdparty/composable_kernel
    url = https://gitclone.com/github.com/ROCm/composable_kernel
```

### TVM .gitmodules

```ini
[submodule "3rdparty/flashinfer"]
    path = 3rdparty/flashinfer
    url = https://ghfast.top/https://github.com/flashinfer-ai/flashinfer.git

[submodule "3rdparty/libflash_attn"]
    path = 3rdparty/libflash_attn
    url = https://ghfast.top/https://github.com/tlc-pack/libflash_attn

[submodule "3rdparty/libbacktrace"]
    path = 3rdparty/libbacktrace
    url = https://ghfast.top/https://github.com/tlc-pack/libbacktrace.git

# 其他子模块使用 gitclone.com 镜像
[submodule "dmlc-core"]
    path = 3rdparty/dmlc-core
    url = https://gitclone.com/github.com/dmlc/dmlc-core.git
```

## 更新步骤

### 方法 1：使用自动化脚本（推荐）

```bash
./scripts/update_submodules.sh
```

### 方法 2：手动执行

```bash
# 1. 同步子模块 URL
git submodule sync --recursive

# 2. 更新所有子模块
git submodule update --init --recursive
```

## 子模块结构

```
tilelang-ascend-my/
├── 3rdparty/
│   ├── catlass          (gitee.com)
│   ├── composable_kernel (gitclone.com)
│   ├── cutlass          (gitclone.com)
│   ├── pto-isa          (gitcode.com)
│   ├── shmem            (gitcode.com)
│   └── tvm/             (gitclone.com)
│       └── 3rdparty/
│           ├── OpenCL-Headers
│           ├── cnpy
│           ├── composable_kernel
│           ├── cutlass
│           ├── cutlass_fpA_intB_gemm
│           ├── dlpack
│           ├── dmlc-core
│           ├── flashinfer      (ghfast.top)
│           ├── libbacktrace    (ghfast.top)
│           ├── libflash_attn   (ghfast.top)
│           └── rang
```

## 常见问题

### Q: gitclone.com 返回 502 错误

**A:** 某些仓库在 gitclone.com 上可能不稳定。可以尝试：
1. 使用 ghfast.top 镜像
2. 暂时跳过该子模块（如果非必需）
3. 配置代理

### Q: 某个提交在镜像中不存在

**A:** 可以：
1. 检出可用的分支：`git checkout origin/main`
2. 从源仓库手动克隆

### Q: 如何验证子模块是否正确更新

**A:** 运行以下命令，不应该有 `+` 前缀的子模块：
```bash
git submodule status --recursive | grep "^+"
```

## 镜像源对比

| 镜像源 | 优点 | 缺点 |
|--------|------|------|
| gitclone.com | 大多数仓库可用 | 部分仓库返回 502 |
| ghfast.top | 稳定性较好 | URL 格式较长 |
| gitee.com | 国内速度快 | 需要手动同步 |
| gitcode.com | 官方维护 | 仓库覆盖不全 |

## 注意事项

1. **不要提交修改后的 .gitmodules 到上游仓库**，这是本地网络环境的解决方案
2. 如果网络环境变化，需要相应调整镜像源
3. 某些子模块可能是可选的（如 flashinfer/libflash_attn），构建时通过 CMake 选项控制

## 更新日期

2026-02-24
