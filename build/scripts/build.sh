#!/bin/bash

# Wallpaper Explorer - 多平台构建脚本
# 支持 Windows, Linux, macOS 的多种打包格式

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 项目信息
PROJECT_NAME="Wallpaper Explorer"
# 版本号动态从 Cargo.toml 获取
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLATFORMS_DIR="$BUILD_DIR/build/platforms"
DIST_DIR="$BUILD_DIR/dist"

# 载入通用函数
source "$BUILD_DIR/build/scripts/common.sh"

# 动态获取版本号
VERSION=$(get_project_version)

# 打印函数
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

# 显示帮助信息
show_help() {
    print_header "$PROJECT_NAME - 多平台构建系统"
    echo ""
    print_message $CYAN "用法: $0 [PLATFORM] [FORMAT] [OPTIONS]"
    echo ""
    print_message $YELLOW "支持的平台:"
    print_message $GREEN "  windows    - Windows 平台"
    print_message $GREEN "  linux      - Linux 平台"
    print_message $GREEN "  macos      - macOS 平台"
    print_message $GREEN "  cross      - 交叉编译"
    print_message $GREEN "  all        - 所有平台"
    echo ""
    print_message $YELLOW "Windows 格式:"
    print_message $GREEN "  installer  - NSIS 安装程序"
    print_message $GREEN "  portable   - 便携版 ZIP"
    print_message $GREEN "  docker     - Docker 镜像"
    echo ""
    print_message $YELLOW "Linux 格式:"
    print_message $GREEN "  deb        - Debian 包"
    print_message $GREEN "  rpm        - RPM 包"
    print_message $GREEN "  appimage   - AppImage"
    print_message $GREEN "  docker     - Docker 镜像"
    echo ""
    print_message $YELLOW "macOS 格式:"
    print_message $GREEN "  dmg        - DMG 镜像"
    print_message $GREEN "  app        - App Bundle"
    print_message $GREEN "  homebrew   - Homebrew Formula"
    echo ""
    print_message $YELLOW "选项:"
    print_message $GREEN "  --clean    - 构建前清理"
    print_message $GREEN "  --verbose  - 详细输出"
    print_message $GREEN "  --release  - 发布构建"
    echo ""
    print_message $YELLOW "示例:"
    print_message $GREEN "  $0 windows installer           # 构建 Windows 安装程序"
    print_message $GREEN "  $0 linux deb --clean          # 清理后构建 Linux DEB"
    print_message $GREEN "  $0 all --release              # 构建所有平台发布版"
}

# 检查依赖
check_dependencies() {
    print_step "检查构建依赖..."
    
    # 检查基本工具
    local required_tools=("cargo" "git")
    for tool in "${required_tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            print_error "$tool 未安装"
            exit 1
        fi
    done
    
    # 检查 Docker (可选)
    if command -v docker &> /dev/null; then
        print_step "Docker 可用"
    else
        print_warning "Docker 未安装，某些构建目标将不可用"
    fi
    
    print_success "依赖检查完成"
}

# 清理函数
clean_build() {
    print_step "清理构建目录..."
    
    # 清理 Cargo 构建缓存
    if [ -d "target" ]; then
        rm -rf target/
    fi
    
    # 清理分发目录
    if [ -d "$DIST_DIR" ]; then
        rm -rf "$DIST_DIR"
        mkdir -p "$DIST_DIR"/{windows,linux,macos,cross}
    fi
    
    print_success "清理完成"
}

# 构建 Windows 平台
build_windows() {
    local format=$1
    print_header "构建 Windows - $format"
    
    case $format in
        "installer")
            bash "$PLATFORMS_DIR/windows/installer/build.sh"
            ;;
        "portable")
            bash "$PLATFORMS_DIR/windows/portable/build.sh"
            ;;
        "docker")
            bash "$PLATFORMS_DIR/windows/docker/build.sh"
            ;;
        *)
            print_error "不支持的 Windows 格式: $format"
            return 1
            ;;
    esac
}

# 构建 Linux 平台
build_linux() {
    local format=$1
    print_header "构建 Linux - $format"
    
    case $format in
        "deb")
            bash "$PLATFORMS_DIR/linux/deb/build.sh"
            ;;
        "rpm")
            bash "$PLATFORMS_DIR/linux/rpm/build.sh"
            ;;
        "appimage")
            bash "$PLATFORMS_DIR/linux/appimage/build.sh"
            ;;
        "docker")
            bash "$PLATFORMS_DIR/linux/docker/build.sh"
            ;;
        *)
            print_error "不支持的 Linux 格式: $format"
            return 1
            ;;
    esac
}

# 构建 macOS 平台
build_macos() {
    local format=$1
    print_header "构建 macOS - $format"
    
    case $format in
        "dmg")
            bash "$PLATFORMS_DIR/macos/dmg/build.sh"
            ;;
        "app")
            bash "$PLATFORMS_DIR/macos/app/build.sh"
            ;;
        "homebrew")
            bash "$PLATFORMS_DIR/macos/homebrew/build.sh"
            ;;
        *)
            print_error "不支持的 macOS 格式: $format"
            return 1
            ;;
    esac
}

# 构建所有平台
build_all() {
    print_header "构建所有平台"
    
    # Windows
    build_windows "installer"
    build_windows "portable"
    
    # Linux
    build_linux "deb"
    build_linux "appimage"
    
    # macOS (如果在 macOS 系统上)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        build_macos "dmg"
        build_macos "app"
    fi
    
    print_success "所有平台构建完成"
}

# 显示构建结果
show_results() {
    print_header "构建结果"
    
    if [ -d "$DIST_DIR" ]; then
        print_step "构建产物:"
        find "$DIST_DIR" -type f -exec ls -lh {} \; | while read line; do
            print_message $GREEN "  $line"
        done
    else
        print_warning "未找到构建产物"
    fi
}

# 主函数
main() {
    local platform=""
    local format=""
    local clean_flag=false
    local verbose_flag=false
    local release_flag=false
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --clean)
                clean_flag=true
                shift
                ;;
            --verbose)
                verbose_flag=true
                set -x
                shift
                ;;
            --release)
                release_flag=true
                export RELEASE_BUILD=true
                shift
                ;;
            windows|linux|macos|cross|all)
                platform=$1
                shift
                ;;
            installer|portable|docker|deb|rpm|appimage|dmg|app|homebrew)
                format=$1
                shift
                ;;
            *)
                print_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查参数
    if [ -z "$platform" ]; then
        show_help
        exit 1
    fi
    
    print_header "$PROJECT_NAME - 多平台构建系统"
    print_step "平台: $platform"
    print_step "格式: $format"
    print_step "版本: $VERSION"
    
    # 检查依赖
    check_dependencies
    
    # 清理 (如果需要)
    if [ "$clean_flag" = true ]; then
        clean_build
    fi
    
    # 设置环境变量
    export PROJECT_NAME="$PROJECT_NAME"
    export VERSION="$VERSION"
    export BUILD_DIR="$BUILD_DIR"
    export DIST_DIR="$DIST_DIR"
    
    # 执行构建
    case $platform in
        "windows")
            if [ -z "$format" ]; then
                print_error "Windows 平台需要指定格式"
                exit 1
            fi
            build_windows "$format"
            ;;
        "linux")
            if [ -z "$format" ]; then
                print_error "Linux 平台需要指定格式"
                exit 1
            fi
            build_linux "$format"
            ;;
        "macos")
            if [ -z "$format" ]; then
                print_error "macOS 平台需要指定格式"
                exit 1
            fi
            build_macos "$format"
            ;;
        "all")
            build_all
            ;;
        *)
            print_error "不支持的平台: $platform"
            exit 1
            ;;
    esac
    
    # 显示结果
    show_results
    
    print_success "构建完成！"
}

# 运行主函数
main "$@" 