#!/bin/bash

# 构建系统验证脚本
# 检查构建环境和配置的正确性

set -e

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

print_header "构建系统验证"

# 检查项目结构
check_project_structure() {
    print_step "检查项目结构..."
    
    local required_files=(
        "Cargo.toml"
        "src/main.rs"
        "build/scripts/build.sh"
        "build/scripts/common.sh"
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

# 检查平台支持
check_platform_support() {
    print_step "检查平台支持..."
    
    local current_os=""
    case "$OSTYPE" in
        linux-gnu*) current_os="Linux" ;;
        darwin*) current_os="macOS" ;;
        cygwin*|msys*|mingw*) current_os="Windows" ;;
        *) current_os="未知" ;;
    esac
    
    print_step "当前操作系统: $current_os"
    
    # 检查可用的构建目标
    print_step "可用的构建目标:"
    
    if check_command cargo; then
        print_step "✓ 本地构建 (Rust)"
    fi
    
    if check_command x86_64-w64-mingw32-gcc; then
        print_step "✓ Windows 交叉编译"
    else
        print_warning "✗ Windows 交叉编译工具链"
    fi
    
    if check_docker_env; then
        print_step "✓ Docker 构建"
    else
        print_warning "✗ Docker 不可用"
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_step "✓ macOS 原生构建"
        
        if check_macos_codesign; then
            print_step "✓ macOS 代码签名"
        else
            print_warning "✗ macOS 代码签名证书"
        fi
    fi
}

# 主验证函数
main() {
    cd "$PROJECT_ROOT"
    
    check_project_structure
    check_rust_env
    check_version_consistency
    check_platform_support
    
    print_success "构建系统验证完成"
}

main "$@" 