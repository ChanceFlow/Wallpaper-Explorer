#!/bin/bash

# Windows 便携版构建脚本 (ZIP)

set -e

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PLATFORM_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$PROJECT_ROOT/dist/windows"

source "$PROJECT_ROOT/build/scripts/common.sh"

print_header "构建 Windows 便携版"

start_timer

# 创建输出目录
ensure_directory "$OUTPUT_DIR"

# 检查 Rust 环境
check_rust_env

# 检查交叉编译工具链
print_step "检查交叉编译工具链..."
if ! check_cross_compile_tools "x86_64-pc-windows-gnu"; then
    print_warning "交叉编译工具链不可用，尝试使用 Docker 构建..."
    
    if check_docker_env; then
        print_step "使用 Docker 构建 Windows 便携版..."
        bash "$PROJECT_ROOT/build/platforms/windows/docker/build.sh"
        exit $?
    else
        print_error "Docker 也不可用，无法构建 Windows 便携版"
        print_step "请安装以下任一工具："
        print_step "1. MinGW-w64 交叉编译工具链"
        print_step "   macOS: brew install mingw-w64"
        print_step "   Ubuntu/Debian: sudo apt install gcc-mingw-w64-x86-64"
        print_step "2. Docker"
        exit 1
    fi
fi

# 添加 Windows 目标
add_rust_target "x86_64-pc-windows-gnu"

# 设置交叉编译环境变量
export CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc
export CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++
export AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar
export CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc

# 切换到项目根目录
cd "$PROJECT_ROOT"

# 构建 Windows 版本
print_step "构建 Windows 可执行文件..."
cargo_build "x86_64-pc-windows-gnu"

# 检查构建产物
BINARY_PATH="target/x86_64-pc-windows-gnu/release/Wallpaper-Explorer.exe"
check_file "$BINARY_PATH"

# 创建便携版目录
PORTABLE_DIR="$OUTPUT_DIR/Wallpaper-Explorer-Portable-v$VERSION"
ensure_directory "$PORTABLE_DIR"

# 复制文件
print_step "打包便携版..."
cp "$BINARY_PATH" "$PORTABLE_DIR/"
cp -r assets/ "$PORTABLE_DIR/"
cp README.md "$PORTABLE_DIR/" 2>/dev/null || true
cp LICENSE "$PORTABLE_DIR/" 2>/dev/null || true

# 创建便携版说明
cat > "$PORTABLE_DIR/便携版说明.txt" << EOF
Wallpaper Explorer - 便携版

这是 Wallpaper Explorer 的便携版本，无需安装即可使用。

使用方法:
1. 双击运行 Wallpaper-Explorer.exe
2. 所有数据将保存在程序目录下
3. 可以复制整个文件夹到其他位置使用

版本: $VERSION
构建时间: $(date '+%Y-%m-%d %H:%M:%S')
目标平台: Windows x86_64

项目主页: https://github.com/your-username/Wallpaper-Explorer
EOF

# 创建 ZIP 包
print_step "创建 ZIP 包..."
cd "$OUTPUT_DIR"
ZIP_NAME="Wallpaper-Explorer-Portable-v$VERSION.zip"

if check_command zip; then
    zip -r "$ZIP_NAME" "Wallpaper-Explorer-Portable-v$VERSION/"
elif check_command 7z; then
    7z a "$ZIP_NAME" "Wallpaper-Explorer-Portable-v$VERSION/"
else
    print_warning "未找到压缩工具，跳过 ZIP 包创建"
fi

# 创建构建信息
cat > "$OUTPUT_DIR/PORTABLE_INFO.txt" << EOF
Wallpaper Explorer - Windows 便携版
构建版本: v$VERSION-$(date +%Y%m%d)
构建时间: $(date '+%Y-%m-%d %H:%M:%S UTC')
包类型: 便携版 ZIP
目标平台: Windows x86_64
构建方式: Cargo 交叉编译

产物说明:
- Wallpaper-Explorer-Portable-v$VERSION/ - 便携版目录
- Wallpaper-Explorer-Portable-v$VERSION.zip - 便携版 ZIP 包
EOF

# 显示结果
print_step "构建产物:"
if [ -f "$ZIP_NAME" ]; then
    local zip_size=$(get_human_file_size "$ZIP_NAME")
    print_success "便携版 ZIP: $ZIP_NAME ($zip_size)"
fi

local dir_size=$(du -sh "Wallpaper-Explorer-Portable-v$VERSION" | cut -f1)
print_success "便携版目录: Wallpaper-Explorer-Portable-v$VERSION ($dir_size)"

end_timer
print_success "Windows 便携版构建完成" 