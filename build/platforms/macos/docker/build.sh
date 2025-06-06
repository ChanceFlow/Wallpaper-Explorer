#!/bin/bash

# macOS App Bundle 构建脚本 (Docker)

set -e

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PLATFORM_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$PROJECT_ROOT/dist/macos"

source "$PROJECT_ROOT/build/scripts/common.sh"

print_header "构建 macOS App Bundle (Docker)"

start_timer

# 创建输出目录
ensure_directory "$OUTPUT_DIR"

# 构建 Docker 镜像
print_step "构建 Docker 镜像..."
docker build -f "$PLATFORM_DIR/Dockerfile" -t wallpaper-macos-app "$PROJECT_ROOT"

# 运行容器生成 App Bundle
print_step "生成 App Bundle..."
docker run --rm \
    -v "$OUTPUT_DIR:/app/output" \
    -e PROJECT_NAME="$PROJECT_NAME" \
    -e VERSION="$VERSION" \
    wallpaper-macos-app

end_timer
print_success "macOS App Bundle (Docker) 构建完成" 