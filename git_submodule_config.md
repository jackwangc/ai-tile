# Git 子模块更新说明

当无法访问 GitHub 时，使用以下方法更新子模块。

## 快速使用

```bash
# 运行自动化脚本（推荐）
./scripts/update_submodules.sh

# 或查看使用帮助
./scripts/update_submodules.sh --help
```

## 脚本功能

- ✅ 自动测试镜像源可用性
- ✅ 自动更新 .gitmodules 文件
- ✅ 自动同步并更新所有子模块
- ✅ 检查子模块状态
- ✅ 备份原始配置文件

## 脚本选项

```bash
# 仅测试镜像源可用性
./scripts/update_submodules.sh --test-only

# 仅查看子模块状态
./scripts/update_submodules.sh --status-only

# 执行完整更新
./scripts/update_submodules.sh --update
```

## 文件说明

- `docs/SUBMODULE_UPDATE_GUIDE.md` - 详细的子模块更新指南
- `scripts/update_submodules.sh` - 自动化更新脚本
- `GIT_SUBMODULE_README.md` - 本文件

## 详细文档

查看 `docs/SUBMODULE_UPDATE_GUIDE.md` 获取：
- 问题诊断
- 修改详情
- 常见问题解答
- 镜像源对比

## 修改的文件

以下文件会被修改：
- `.gitmodules` - 主项目子模块配置
- `3rdparty/tvm/.gitmodules` - TVM 子模块配置

原始文件会自动备份为 `.backup`。

## 验证更新

运行以下命令验证所有子模块都已正确更新：

```bash
git submodule status --recursive
```

如果没有 `+` 或 `-` 前缀，说明所有子模块都是最新的。
