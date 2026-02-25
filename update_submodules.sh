#!/bin/bash

#===============================================================================
# 子模块更新脚本
# 用于在无法直接访问 GitHub 的环境中更新子模块
#===============================================================================

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否在项目根目录
check_project_root() {
    if [ ! -f ".gitmodules" ]; then
        log_error "未找到 .gitmodules 文件，请在项目根目录运行此脚本"
        exit 1
    fi
    log_info "当前目录: $(pwd)"
}

# 测试镜像源可用性
test_mirror() {
    local url=$1
    local name=$2

    if curl -I --connect-timeout 5 "$url" > /dev/null 2>&1; then
        log_info "$name 可访问"
        return 0
    else
        log_warn "$name 不可访问"
        return 1
    fi
}

# 修改 .gitmodules 中的镜像源
update_gitmodules() {
    log_info "正在更新 .gitmodules 文件..."

    # 备份原文件
    cp .gitmodules .gitmodules.backup
    log_info "已备份 .gitmodules 到 .gitmodules.backup"

    # 主项目子模块替换
    # cutlass 使用 ghfast.top（gitclone.com 不可访问）
    sed -i 's|url = https://github.com/NVIDIA/cutlass|url = https://ghfast.top/https://github.com/NVIDIA/cutlass|' .gitmodules
    sed -i 's|url = https://gitclone.com/github.com/NVIDIA/cutlass|url = https://ghfast.top/https://github.com/NVIDIA/cutlass|' .gitmodules
    sed -i 's|url = https://github.com/TileLang/tvm|url = https://gitclone.com/github.com/TileLang/tvm|' .gitmodules
    sed -i 's|url = https://github.com/ROCm/composable_kernel|url = https://gitclone.com/github.com/ROCm/composable_kernel|' .gitmodules

    log_info "主项目 .gitmodules 已更新"
}

# 更新 TVM 的 .gitmodules
update_tvm_gitmodules() {
    if [ -d "3rdparty/tvm" ]; then
        log_info "正在更新 TVM .gitmodules 文件..."

        # 备份
        cp 3rdparty/tvm/.gitmodules 3rdparty/tvm/.gitmodules.backup

        # 批量替换 GitHub URL 为 gitclone.com 镜像
        sed -i 's|url = https://github.com/|url = https://gitclone.com/github.com/|' 3rdparty/tvm/.gitmodules

        # 特殊处理：cutlass 和 OpenCL-Headers 使用 ghfast.top（gitclone.com 不可访问）
        sed -i 's|url = https://gitclone.com/github.com/NVIDIA/cutlass|url = https://ghfast.top/https://github.com/NVIDIA/cutlass|' 3rdparty/tvm/.gitmodules
        sed -i 's|url = https://gitclone.com/github.com/KhronosGroup/OpenCL-Headers|url = https://ghfast.top/https://github.com/KhronosGroup/OpenCL-Headers|' 3rdparty/tvm/.gitmodules

        # 特殊处理 flashinfer、libflash_attn 和 libbacktrace（使用 ghfast.top）
        sed -i 's|url = https://gitclone.com/github.com/tlc-pack/libflash_attn|url = https://ghfast.top/https://github.com/tlc-pack/libflash_attn|' 3rdparty/tvm/.gitmodules
        sed -i 's|url = https://gitclone.com/github.com/flashinfer-ai/flashinfer.git|url = https://ghfast.top/https://github.com/flashinfer-ai/flashinfer.git|' 3rdparty/tvm/.gitmodules
        sed -i 's|url = https://gitclone.com/github.com/tlc-pack/libbacktrace.git|url = https://ghfast.top/https://github.com/tlc-pack/libbacktrace.git|' 3rdparty/tvm/.gitmodules

        log_info "TVM .gitmodules 已更新"
    else
        log_warn "未找到 TVM 子模块，跳过"
    fi
}

# 同步并更新子模块
update_submodules() {
    log_info "同步子模块 URL..."
    git submodule sync --recursive

    log_info "更新子模块（这可能需要一些时间）..."
    if git submodule update --init --recursive; then
        log_info "子模块更新成功！"
    else
        log_warn "部分子模块更新失败，但主要子模块可能已更新"
    fi
}

# 检查子模块状态
check_submodule_status() {
    log_info "检查子模块状态..."

    local outdated=$(git submodule status --recursive 2>/dev/null | grep "^+" | wc -l)
    if [ "$outdated" -eq 0 ]; then
        log_info "所有子模块都是最新的！"
    else
        log_warn "有 $outdated 个子模块需要更新"
        git submodule status --recursive 2>/dev/null | grep "^+"
    fi
}

# 显示帮助信息
show_help() {
    cat << EOF
子模块更新脚本

用法: $0 [选项]

选项:
    -h, --help          显示此帮助信息
    -t, --test-only     仅测试镜像源可用性，不更新
    -s, --status-only   仅显示子模块状态，不更新
    -u, --update        执行完整更新（默认）

示例:
    $0                  # 执行完整更新
    $0 -t              # 仅测试镜像源
    $0 -s              # 仅查看状态

镜像源:
    - gitclone.com     主要镜像（大部分子模块）
    - ghfast.top       NVIDIA/cutlass, KhronosGroup/OpenCL-Headers, flashinfer, libflash_attn, libbacktrace
    - gitee.com        catlass (已有)
    - gitcode.com      pto-isa/shmem (已有)
EOF
}

# 主函数
main() {
    local test_only=false
    local status_only=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -t|--test-only)
                test_only=true
                shift
                ;;
            -s|--status-only)
                status_only=true
                shift
                ;;
            -u|--update)
                shift
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done

    check_project_root

    # 测试镜像源
    log_info "测试镜像源可用性..."
    test_mirror "https://gitclone.com" "gitclone.com"
    test_mirror "https://ghfast.top" "ghfast.top"
    test_mirror "https://gitee.com" "gitee.com"
    test_mirror "https://gitcode.com" "gitcode.com"

    if [ "$test_only" = true ]; then
        log_info "镜像源测试完成"
        exit 0
    fi

    if [ "$status_only" = true ]; then
        check_submodule_status
        exit 0
    fi

    # 执行更新
    log_info "开始更新子模块..."
    update_gitmodules
    update_tvm_gitmodules
    update_submodules
    check_submodule_status

    log_info "更新完成！"
}

# 运行主函数
main "$@"
