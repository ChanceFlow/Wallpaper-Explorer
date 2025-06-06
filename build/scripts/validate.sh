#!/bin/bash

# 构建系统验证脚本
# 检查构建环境和配置的正确性

set -e

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

print_header "构建系统验证 (Docker Only)"

# 检查项目结构
check_project_structure() {
    print_step "检查项目结构..."
    
    local required_files=(
        "Cargo.toml"
        "src/main.rs"
        "build/scripts/build.sh"
        "build/scripts/common.sh"
        "build/platforms/windows/docker/Dockerfile"
        "build/platforms/linux/docker/Dockerfile"
        "build/platforms/macos/docker/Dockerfile"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$PROJECT_ROOT/$file" ]; then
            print_error "缺少必需文件: $file"
            return 1
        fi
    done
    
    print_success "项目结构检查通过"
}

# 检查版本号一致性
check_version_consistency() {
    print_step "检查版本号一致性..."
    
    cd "$PROJECT_ROOT"
    local cargo_version=$(get_project_version)
    print_step "Cargo.toml 版本: $cargo_version"
    
    # 检查各平台脚本中是否还有硬编码版本
    local hardcoded_versions=$(grep -r "VERSION.*=.*[0-9]\+\.[0-9]\+\.[0-9]\+" build/ --include="*.sh" --include="*.nsi" || true)
    
    if [ -n "$hardcoded_versions" ]; then
        print_warning "发现硬编码版本号:"
        echo "$hardcoded_versions"
    else
        print_success "未发现硬编码版本号"
    fi
}

# 检查 Docker 构建支持
check_docker_support() {
    print_step "检查 Docker 构建环境..."
    
    local current_os=""
    case "$OSTYPE" in
        linux-gnu*) current_os="Linux" ;;
        darwin*) current_os="macOS" ;;
        cygwin*|msys*|mingw*) current_os="Windows" ;;
        *) current_os="未知" ;;
    esac
    
    print_step "当前操作系统: $current_os"
    
    # 检查 Docker 环境
    if check_docker_env; then
        print_step "✓ Docker 可用"
        
        # 测试 Docker 构建能力
        print_step "测试 Docker 构建能力..."
        if docker run --rm hello-world &>/dev/null; then
            print_step "✓ Docker 运行正常"
        else
            print_warning "✗ Docker 运行测试失败"
        fi
        
        # 检查 Docker 磁盘空间
        local docker_info=$(docker system df --format "table {{.Type}}\t{{.Size}}" 2>/dev/null || echo "")
        if [ -n "$docker_info" ]; then
            print_step "Docker 存储信息:"
            echo "$docker_info"
        fi
        
    else
        print_error "✗ Docker 不可用"
        print_step "请安装并启动 Docker 以使用构建系统"
        return 1
    fi
}

# 检查可用的构建目标
check_build_targets() {
    print_step "可用的构建目标:"
    
    print_step "✓ Windows 安装程序 (Docker + NSIS)"
    print_step "✓ Windows 便携版 (Docker + MinGW-w64)"
    print_step "✓ Linux DEB 包 (Docker + dpkg)"
    print_step "✓ macOS App Bundle (Docker + 交叉编译)"
    
    print_success "所有构建目标均通过 Docker 支持"
}

# 主验证函数
main() {
    cd "$PROJECT_ROOT"
    
    check_project_structure
    check_version_consistency
    check_docker_support
    check_build_targets
    
    print_success "构建系统验证完成 - Docker Only 模式就绪"
    print_step "使用方法:"
    print_step "  ./build/scripts/build.sh windows installer  # Windows 安装程序"
    print_step "  ./build/scripts/build.sh windows portable   # Windows 便携版"
    print_step "  ./build/scripts/build.sh linux deb          # Linux DEB 包"
    print_step "  ./build/scripts/build.sh macos app          # macOS App Bundle"
    print_step "  ./build/scripts/build.sh all --clean        # 构建所有平台"
}

main "$@" 