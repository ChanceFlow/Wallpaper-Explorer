#!/bin/bash

# Linux DEB 包构建脚本 (Docker Only)

set -e

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PLATFORM_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$PROJECT_ROOT/dist/linux"

source "$PROJECT_ROOT/build/scripts/common.sh"

print_header "构建 Linux DEB 包"

start_timer

# 创建输出目录
ensure_directory "$OUTPUT_DIR"

# 检查 Docker 环境
if ! check_docker_env; then
    print_error "Docker 不可用，无法构建 Linux DEB 包"
    print_step "请安装并启动 Docker"
    exit 1
fi

# 使用 Docker 构建
print_step "使用 Docker 构建 Linux DEB 包..."
bash "$PROJECT_ROOT/build/platforms/linux/docker/build.sh"

end_timer
print_success "Linux DEB 包构建完成" 