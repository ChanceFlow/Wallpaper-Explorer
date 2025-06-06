#!/bin/bash
set -e

echo "🚀 开始构建 Linux DEB 包..."

# 显示文件列表
echo "📁 当前目录文件:"
ls -la

# 确保输出目录存在
mkdir -p /app/output

# 创建 DEB 包结构
DEB_NAME="wallpaper-explorer_${VERSION}_amd64"
DEB_DIR="/app/output/$DEB_NAME"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/bin"
mkdir -p "$DEB_DIR/usr/share/applications"
mkdir -p "$DEB_DIR/usr/share/pixmaps"
mkdir -p "$DEB_DIR/usr/share/wallpaper-explorer"

echo "📦 打包 DEB 文件..."

# 复制二进制文件
cp Wallpaper-Explorer "$DEB_DIR/usr/bin/wallpaper-explorer"
chmod +x "$DEB_DIR/usr/bin/wallpaper-explorer"

# 复制资源文件
cp -r assets/ "$DEB_DIR/usr/share/wallpaper-explorer/"

# 创建桌面文件
cat > "$DEB_DIR/usr/share/applications/wallpaper-explorer.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Wallpaper Explorer
Comment=现代化桌面壁纸管理应用程序
Exec=wallpaper-explorer
Icon=wallpaper-explorer
Terminal=false
StartupNotify=true
Categories=Graphics;Photography;
Keywords=wallpaper;background;image;desktop;
EOF

# 创建控制文件
cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: wallpaper-explorer
Version: $VERSION
Section: graphics
Priority: optional
Architecture: amd64
Depends: libc6, libgtk-3-0
Maintainer: Wallpaper Explorer Team <team@wallpaper-explorer.com>
Description: 现代化桌面壁纸管理应用程序
 Wallpaper Explorer 是一个现代化的桌面壁纸管理应用程序，
 使用 Rust 和 Slint 构建，提供直观的界面和强大的功能。
 .
 主要特性:
  * 壁纸浏览和管理
  * 缩略图预览
  * 多格式支持
  * 现代化界面
EOF

# 创建安装后脚本
cat > "$DEB_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

# 更新桌面数据库
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications
fi

# 更新图标缓存
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q /usr/share/pixmaps
fi

exit 0
EOF

chmod +x "$DEB_DIR/DEBIAN/postinst"

# 创建卸载前脚本
cat > "$DEB_DIR/DEBIAN/prerm" << 'EOF'
#!/bin/bash
set -e

# 这里可以添加卸载前的清理工作

exit 0
EOF

chmod +x "$DEB_DIR/DEBIAN/prerm"

# 构建 DEB 包
echo "📦 构建 DEB 包..."
cd /app/output

dpkg-deb --build "$DEB_NAME"
DEB_FILE="${DEB_NAME}.deb"

# 创建构建信息文件
cat > "/app/output/DEB_INFO.txt" << EOF
Wallpaper Explorer - Linux DEB 包
构建版本: v$VERSION-$(date +%Y%m%d)
构建时间: $(date '+%Y-%m-%d %H:%M:%S UTC')
包类型: DEB 包
目标平台: Linux x86_64 (amd64)
构建方式: Docker + Cargo 编译

产物说明:
- $DEB_NAME/ - DEB 包结构目录
- $DEB_FILE - DEB 安装包
EOF

# 检查构建结果
if [ -f "/app/output/$DEB_FILE" ]; then
    echo "✅ DEB 包构建成功！"
    
    # 显示文件信息
    echo "📊 DEB 包信息:"
    ls -lh "/app/output/$DEB_FILE"
    ls -lh "/app/output/$DEB_NAME/"
    
    echo "🎉 构建完成！DEB 包已保存到: /app/output/"
else
    echo "❌ DEB 包构建失败"
    exit 1
fi 