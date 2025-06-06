#!/bin/bash

# Wallpaper Explorer - Windows 构建脚本
# 支持多架构交叉编译的 Docker 构建系统
# 使用 BuildKit 和 buildx 进行高性能构建

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置变量
PROJECT_NAME="Wallpaper Explorer"
BUILD_OUTPUT_DIR="./dist"
DOCKER_BUILDKIT=1
COMPOSE_DOCKER_CLI_BUILD=1

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    echo ""
    print_message $CYAN "=================================================="
    print_message $CYAN "$1"
    print_message $CYAN "=================================================="
}

print_step() {
    print_message $BLUE "🔸 $1"
}

print_success() {
    print_message $GREEN "✅ $1"
}

print_warning() {
    print_message $YELLOW "⚠️  $1"
}

print_error() {
    print_message $RED "❌ $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 命令未找到，请确保已安装"
        exit 1
    fi
}

# 检查 Docker BuildKit 支持
check_buildkit() {
    print_step "检查 Docker BuildKit 支持..."
    
    # 检查 Docker 版本
    docker_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "unknown")
    print_step "Docker 版本: $docker_version"
    
    # 检查 buildx 插件
    if docker buildx version &> /dev/null; then
        buildx_version=$(docker buildx version | head -n 1)
        print_step "Docker Buildx: $buildx_version"
    else
        print_error "Docker Buildx 未安装或不可用"
        exit 1
    fi
    
    # 检查当前构建器
    current_builder=$(docker buildx inspect --bootstrap 2>/dev/null | grep "^Name:" | awk '{print $2}' || echo "default")
    print_step "当前构建器: $current_builder"
    
    # 列出支持的平台
    print_step "支持的构建平台:"
    docker buildx ls | grep -E "^\s*(default|[a-zA-Z])" | while read line; do
        echo "  $line"
    done
}

# 创建和配置 buildx 构建器
setup_builder() {
    print_step "设置多平台构建器..."
    
    # 检查是否存在专用构建器
    if docker buildx inspect wallpaper-builder &>/dev/null; then
        print_step "发现已存在的构建器: wallpaper-builder"
        docker buildx use wallpaper-builder
    else
        print_step "创建新的多平台构建器..."
        docker buildx create \
            --name wallpaper-builder \
            --driver docker-container \
            --use \
            --bootstrap
        print_success "构建器 'wallpaper-builder' 创建成功"
    fi
    
    # 显示构建器信息
    print_step "构建器详细信息:"
    docker buildx inspect wallpaper-builder
}

# 清理函数
cleanup() {
    print_step "清理现有容器和镜像..."
    
    # 停止并删除现有容器
    if docker ps -a --format "table {{.Names}}" | grep -q "wallpaper-explorer-windows-builder"; then
        print_step "停止现有构建容器..."
        docker stop wallpaper-explorer-windows-builder 2>/dev/null || true
        docker rm wallpaper-explorer-windows-builder 2>/dev/null || true
    fi
    
    # 清理悬挂的镜像
    if [ "$(docker images -q -f dangling=true)" ]; then
        print_step "清理悬挂镜像..."
        docker rmi $(docker images -q -f dangling=true) 2>/dev/null || true
    fi
    
    print_success "清理完成"
}

# 主构建函数
build_windows() {
    print_header "🚀 开始构建 Windows 版本 $PROJECT_NAME"
    
    # 显示构建信息
    host_platform=$(uname -m)
    print_step "主机平台: $(uname -s)/$(uname -m)"
    print_step "目标平台: Windows/x86_64"
    print_step "构建方式: Docker 交叉编译"
    print_step "输出目录: $BUILD_OUTPUT_DIR"
    
    # 创建输出目录
    mkdir -p "$BUILD_OUTPUT_DIR"
    
    # 设置环境变量
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1
    export DOCKER_DEFAULT_PLATFORM="linux/$(uname -m)"
    
    print_step "环境变量:"
    print_step "  DOCKER_BUILDKIT=$DOCKER_BUILDKIT"
    print_step "  COMPOSE_DOCKER_CLI_BUILD=$COMPOSE_DOCKER_CLI_BUILD"
    print_step "  DOCKER_DEFAULT_PLATFORM=$DOCKER_DEFAULT_PLATFORM"
    
    # 使用 docker-compose 构建
    print_step "启动 Docker 构建容器..."
    print_warning "这可能需要几分钟时间，请耐心等待..."
    
    # 构建和运行容器
    if docker-compose up --build; then
        print_success "Docker 构建容器运行成功"
    else
        print_error "Docker 构建失败"
        exit 1
    fi
    
    # 清理容器
    print_step "清理构建容器..."
    docker-compose down 2>/dev/null || true
}

# 验证构建结果
verify_build() {
    print_header "🔍 验证构建结果"
    
    if [ ! -d "$BUILD_OUTPUT_DIR" ]; then
        print_error "输出目录不存在: $BUILD_OUTPUT_DIR"
        exit 1
    fi
    
    # 检查 ZIP 文件
    zip_file=$(find "$BUILD_OUTPUT_DIR" -name "*.zip" | head -n 1)
    if [ -n "$zip_file" ]; then
        zip_size=$(ls -lh "$zip_file" | awk '{print $5}')
        print_success "ZIP 包: $(basename "$zip_file") ($zip_size)"
    else
        print_error "未找到 ZIP 文件"
        exit 1
    fi
    
    # 检查可执行文件
    exe_file=$(find "$BUILD_OUTPUT_DIR" -name "*.exe" | head -n 1)
    if [ -n "$exe_file" ]; then
        exe_size=$(ls -lh "$exe_file" | awk '{print $5}')
        print_success "可执行文件: $(basename "$exe_file") ($exe_size)"
    else
        print_error "未找到可执行文件"
        exit 1
    fi
    
    # 显示输出目录内容
    print_step "构建产物详情:"
    ls -la "$BUILD_OUTPUT_DIR"
    
    print_header "📊 构建统计"
    total_size=$(du -sh "$BUILD_OUTPUT_DIR" | cut -f1)
    file_count=$(find "$BUILD_OUTPUT_DIR" -type f | wc -l)
    print_step "总大小: $total_size"
    print_step "文件数量: $file_count"
}

# 显示使用说明
show_usage() {
    print_header "📖 使用说明"
    echo ""
    print_step "构建完成！您可以找到以下文件："
    echo ""
    print_message $GREEN "📦 ZIP 压缩包: $BUILD_OUTPUT_DIR/Wallpaper-Explorer-Windows-v0.1.0.zip"
    print_message $GREEN "📁 解压版本: $BUILD_OUTPUT_DIR/Wallpaper-Explorer/"
    echo ""
    print_step "使用方法："
    print_message $CYAN "1. 将 ZIP 文件传输到 Windows 系统"
    print_message $CYAN "2. 解压到任意目录"
    print_message $CYAN "3. 双击 Wallpaper-Explorer.exe 运行"
    echo ""
    print_step "系统要求："
    print_message $YELLOW "- Windows 10 或更高版本"
    print_message $YELLOW "- x64 (64位) 架构"
    echo ""
}

# 主函数
main() {
    print_header "🎯 $PROJECT_NAME - Windows 交叉编译构建系统"
    
    # 检查必要的命令
    print_step "检查系统环境..."
    check_command docker
    check_command docker-compose
    
    # 检查 BuildKit 支持
    check_buildkit
    
    # 设置构建器
    setup_builder
    
    # 清理环境
    cleanup
    
    # 开始构建
    build_windows
    
    # 验证结果
    verify_build
    
    # 显示使用说明
    show_usage
    
    print_header "🎉 构建完成！"
    print_success "Windows 版本 $PROJECT_NAME 构建成功！"
}

# 错误处理
trap 'print_error "构建过程中发生错误，正在清理..."; docker-compose down 2>/dev/null || true; exit 1' ERR

# 执行主函数
main "$@" 