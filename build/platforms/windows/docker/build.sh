#!/bin/bash

# Windows 便携版构建脚本 (Docker)

set -e

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PLATFORM_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$PROJECT_ROOT/dist/windows"

source "$PROJECT_ROOT/build/scripts/common.sh"

print_header "构建 Windows 便携版 (Docker)"

start_timer

# 创建输出目录
ensure_directory "$OUTPUT_DIR"

# 构建 Docker 镜像
print_step "构建 Docker 镜像..."
docker build -f "$PLATFORM_DIR/Dockerfile" -t wallpaper-windows-portable "$PROJECT_ROOT"

# 运行容器生成便携版
print_step "生成便携版..."
docker run --rm \
    -v "$OUTPUT_DIR:/app/output" \
    -e PROJECT_NAME="$PROJECT_NAME" \
    -e VERSION="$VERSION" \
    wallpaper-windows-portable

end_timer
print_success "Windows 便携版 (Docker) 构建完成" 