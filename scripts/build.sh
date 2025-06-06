#!/bin/bash

# 构建脚本
# 用于构建发布版本

set -e

echo "🔨 构建 Wallpaper Explorer..."

# 清理之前的构建
echo "🧹 清理之前的构建..."
cargo clean

# 构建发布版本
echo "📦 构建发布版本..."
cargo build --release

# 检查构建结果
if [ -f "target/release/Wallpaper-Explorer" ] || [ -f "target/release/Wallpaper-Explorer.exe" ]; then
    echo "✅ 构建成功！"
    echo "📍 可执行文件位置: target/release/"
    
    # 显示文件大小
    if command -v du &> /dev/null; then
        echo "📊 文件大小:"
        du -h target/release/Wallpaper-Explorer* 2>/dev/null || true
    fi
else
    echo "❌ 构建失败！"
    exit 1
fi 