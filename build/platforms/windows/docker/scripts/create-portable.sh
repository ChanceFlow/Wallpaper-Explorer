#!/bin/bash
set -e

echo "🚀 开始构建 Windows 便携版..."

# 显示文件列表
echo "📁 当前目录文件:"
ls -la

# 确保输出目录存在
mkdir -p /app/output

# 创建便携版目录
PORTABLE_DIR="/app/output/Wallpaper-Explorer-Portable-v$VERSION"
mkdir -p "$PORTABLE_DIR"

echo "📦 打包便携版文件..."

# 复制主程序
cp Wallpaper-Explorer.exe "$PORTABLE_DIR/"

# 复制资源文件
cp -r assets/ "$PORTABLE_DIR/"

# 复制文档文件
cp README.md "$PORTABLE_DIR/" 2>/dev/null || true
cp LICENSE "$PORTABLE_DIR/" 2>/dev/null || true

# 创建便携版说明文件
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
构建方式: Docker + MinGW-w64 交叉编译

项目主页: https://github.com/your-username/Wallpaper-Explorer
EOF

# 创建启动脚本
cat > "$PORTABLE_DIR/启动.bat" << EOF
@echo off
chcp 65001 >nul
echo 启动 Wallpaper Explorer...
start "" "Wallpaper-Explorer.exe"
EOF

# 创建 ZIP 包
echo "📦 创建 ZIP 包..."
cd /app/output
ZIP_NAME="Wallpaper-Explorer-Portable-v$VERSION.zip"
zip -r "$ZIP_NAME" "Wallpaper-Explorer-Portable-v$VERSION/"

# 创建构建信息文件
cat > "/app/output/PORTABLE_INFO.txt" << EOF
Wallpaper Explorer - Windows 便携版
构建版本: v$VERSION-$(date +%Y%m%d)
构建时间: $(date '+%Y-%m-%d %H:%M:%S UTC')
包类型: 便携版 ZIP
目标平台: Windows x86_64
构建方式: Docker + MinGW-w64 交叉编译

产物说明:
- Wallpaper-Explorer-Portable-v$VERSION/ - 便携版目录
- Wallpaper-Explorer-Portable-v$VERSION.zip - 便携版 ZIP 包
EOF

# 检查构建结果
if [ -f "/app/output/$ZIP_NAME" ]; then
    echo "✅ 便携版构建成功！"
    
    # 显示文件信息
    echo "📊 便携版信息:"
    ls -lh "/app/output/$ZIP_NAME"
    ls -lh "/app/output/Wallpaper-Explorer-Portable-v$VERSION/"
    
    echo "🎉 构建完成！便携版已保存到: /app/output/"
else
    echo "❌ 便携版构建失败"
    exit 1
fi 