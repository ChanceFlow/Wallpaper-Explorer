#!/bin/bash

# Linux DEB 包构建脚本

set -e

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PLATFORM_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$PROJECT_ROOT/dist/linux"

source "$PROJECT_ROOT/build/scripts/common.sh"

print_header "构建 Linux DEB 包"

start_timer

# 创建输出目录
ensure_directory "$OUTPUT_DIR"

# 检查 Rust 环境
check_rust_env

# 切换到项目根目录
cd "$PROJECT_ROOT"

# 构建 Linux 版本
print_step "构建 Linux 可执行文件..."
cargo_build ""

# 检查构建产物
BINARY_PATH="target/release/Wallpaper-Explorer"
check_file "$BINARY_PATH"

# 创建 DEB 包结构
DEB_NAME="wallpaper-explorer_${VERSION}_amd64"
DEB_DIR="$OUTPUT_DIR/$DEB_NAME"
ensure_directory "$DEB_DIR/DEBIAN"
ensure_directory "$DEB_DIR/usr/bin"
ensure_directory "$DEB_DIR/usr/share/applications"
ensure_directory "$DEB_DIR/usr/share/pixmaps"
ensure_directory "$DEB_DIR/usr/share/wallpaper-explorer"

# 复制二进制文件
print_step "打包 DEB 文件..."
cp "$BINARY_PATH" "$DEB_DIR/usr/bin/wallpaper-explorer"
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
print_step "构建 DEB 包..."
cd "$OUTPUT_DIR"

if check_command dpkg-deb; then
    dpkg-deb --build "$DEB_NAME"
    DEB_FILE="${DEB_NAME}.deb"
elif check_command fakeroot && check_command dpkg-deb; then
    fakeroot dpkg-deb --build "$DEB_NAME"
    DEB_FILE="${DEB_NAME}.deb"
else
    print_warning "未找到 dpkg-deb，跳过 DEB 包创建"
    DEB_FILE=""
fi

# 创建构建信息
cat > "$OUTPUT_DIR/DEB_INFO.txt" << EOF
Wallpaper Explorer - Linux DEB 包
构建版本: v$VERSION-$(date +%Y%m%d)
构建时间: $(date '+%Y-%m-%d %H:%M:%S UTC')
包类型: DEB 包
目标平台: Linux x86_64 (amd64)
构建方式: Cargo 本地编译

产物说明:
- $DEB_NAME/ - DEB 包结构目录
- $DEB_FILE - DEB 安装包
EOF

# 显示结果
print_step "构建产物:"
if [ -n "$DEB_FILE" ] && [ -f "$DEB_FILE" ]; then
    deb_size=$(get_human_file_size "$DEB_FILE")
    print_success "DEB 包: $DEB_FILE ($deb_size)"
fi

dir_size=$(du -sh "$DEB_NAME" | cut -f1)
print_success "DEB 结构: $DEB_NAME ($dir_size)"

end_timer
print_success "Linux DEB 包构建完成" 