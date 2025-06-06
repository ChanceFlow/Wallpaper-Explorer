#!/bin/bash

# Windows 安装程序构建脚本 (NSIS)

set -e

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PLATFORM_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$PROJECT_ROOT/dist/windows"

source "$PROJECT_ROOT/build/scripts/common.sh"

print_header "构建 Windows 安装程序"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 构建 Docker 镜像
print_step "构建 Docker 镜像..."
docker build -f "$PLATFORM_DIR/Dockerfile" -t wallpaper-windows-installer "$PROJECT_ROOT"

# 运行容器生成安装程序
print_step "生成安装程序..."
docker run --rm \
    -v "$OUTPUT_DIR:/app/output" \
    -e PROJECT_NAME="$PROJECT_NAME" \
    -e VERSION="$VERSION" \
    wallpaper-windows-installer

print_success "Windows 安装程序构建完成" 