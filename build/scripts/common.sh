#!/bin/bash

# 通用构建工具函数

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 命令未找到"
        return 1
    fi
    return 0
}

# 检查文件是否存在
check_file() {
    if [ ! -f "$1" ]; then
        print_error "文件不存在: $1"
        return 1
    fi
    return 0
}

# 检查目录是否存在
check_directory() {
    if [ ! -d "$1" ]; then
        print_error "目录不存在: $1"
        return 1
    fi
    return 0
}

# 创建目录
ensure_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        print_step "创建目录: $1"
    fi
}

# 获取文件大小
get_file_size() {
    if [ -f "$1" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            stat -f%z "$1"
        else
            stat -c%s "$1"
        fi
    else
        echo "0"
    fi
}

# 获取人类可读的文件大小
get_human_file_size() {
    if [ -f "$1" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            ls -lh "$1" | awk '{print $5}'
        else
            ls -lh "$1" | awk '{print $5}'
        fi
    else
        echo "0B"
    fi
}

# 计算构建时间
start_timer() {
    BUILD_START_TIME=$(date +%s)
}

end_timer() {
    if [ -n "$BUILD_START_TIME" ]; then
        BUILD_END_TIME=$(date +%s)
        BUILD_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))
        
        local minutes=$((BUILD_DURATION / 60))
        local seconds=$((BUILD_DURATION % 60))
        
        if [ $minutes -gt 0 ]; then
            print_step "构建耗时: ${minutes}分${seconds}秒"
        else
            print_step "构建耗时: ${seconds}秒"
        fi
    fi
}

# 清理函数
cleanup_on_exit() {
    end_timer
    if [ $? -ne 0 ]; then
        print_error "构建失败"
    fi
}

# 设置退出处理
trap cleanup_on_exit EXIT

# 获取项目信息
get_project_version() {
    if [ -f "Cargo.toml" ]; then
        grep '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/'
    else
        echo "0.1.0"
    fi
}

get_project_name() {
    if [ -f "Cargo.toml" ]; then
        grep '^name = ' Cargo.toml | sed 's/name = "\(.*\)"/\1/'
    else
        echo "Wallpaper-Explorer"
    fi
}

# 检查 Docker 环境
check_docker_env() {
    check_command docker || return 1
    
    if ! docker info &> /dev/null; then
        print_error "Docker 守护进程未运行"
        return 1
    fi
    
    local docker_version=$(docker --version | awk '{print $3}' | sed 's/,//')
    print_step "Docker 版本: $docker_version"
    
    return 0
} 