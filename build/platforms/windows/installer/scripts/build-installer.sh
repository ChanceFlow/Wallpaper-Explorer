#!/bin/bash
set -e

echo "🚀 开始构建 Windows 安装程序..."

# 显示文件列表
echo "📁 当前目录文件:"
ls -la

# 编译 NSIS 安装程序
echo "📦 编译 NSIS 安装程序..."
cd /installer

# 替换版本号
sed "s/\${VERSION}/$VERSION/g" nsis/wallpaper-explorer.nsi > wallpaper-explorer.nsi

makensis wallpaper-explorer.nsi

# 确保输出目录存在
mkdir -p /app/output

# 检查输出
if [ -f "/app/output/Wallpaper-Explorer-Setup-v$VERSION.exe" ]; then
    echo "✅ 安装程序构建成功！"
    
    # 创建版本信息
    echo "Wallpaper Explorer - Windows 安装程序" > /app/output/INSTALLER_INFO.txt
    echo "构建版本: v$VERSION-$(date +%Y%m%d)" >> /app/output/INSTALLER_INFO.txt
    echo "构建时间: $(date '+%Y-%m-%d %H:%M:%S UTC')" >> /app/output/INSTALLER_INFO.txt
    echo "安装程序类型: NSIS (.exe)" >> /app/output/INSTALLER_INFO.txt
    echo "目标平台: Windows x86_64" >> /app/output/INSTALLER_INFO.txt
    echo "构建方式: Docker + MinGW-w64 交叉编译" >> /app/output/INSTALLER_INFO.txt
    
    # 显示文件信息
    echo "📊 安装程序信息:"
    ls -lh /app/output/Wallpaper-Explorer-Setup-v$VERSION.exe
    
    echo "🎉 构建完成！安装程序已保存到: /app/output/"
else
    echo "❌ 安装程序构建失败"
    exit 1
fi 