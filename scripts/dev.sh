#!/bin/bash

# 开发环境脚本
# 用于快速启动开发环境

set -e

echo "🚀 启动 Wallpaper Explorer 开发环境..."

# 检查 Rust 环境
if ! command -v cargo &> /dev/null; then
    echo "❌ 错误: 未找到 Cargo，请先安装 Rust"
    exit 1
fi

# 检查依赖
echo "📦 检查依赖..."
cargo check

# 运行测试
echo "🧪 运行测试..."
cargo test

# 启动应用程序（开发模式）
echo "🎯 启动应用程序（开发模式）..."
RUST_LOG=debug cargo run

echo "✅ 开发环境启动完成！" 