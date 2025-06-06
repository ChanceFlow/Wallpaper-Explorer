#!/bin/bash

# macOS DMG 安装镜像构建脚本

set -e

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PLATFORM_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$PROJECT_ROOT/dist/macos"

source "$PROJECT_ROOT/build/scripts/common.sh"

print_header "构建 macOS DMG 安装镜像"

start_timer

# 检查 macOS 环境
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "DMG 镜像只能在 macOS 系统上构建"
    exit 1
fi

# 创建输出目录
ensure_directory "$OUTPUT_DIR"

# 检查是否已有 App Bundle
APP_NAME="Wallpaper Explorer.app"
APP_DIR="$OUTPUT_DIR/$APP_NAME"

if [ ! -d "$APP_DIR" ]; then
    print_step "未找到 App Bundle，先构建..."
    bash "$PROJECT_ROOT/build/platforms/macos/app/build.sh"
fi

if [ ! -d "$APP_DIR" ]; then
    print_error "App Bundle 不存在: $APP_DIR"
    exit 1
fi

# DMG 配置
DMG_NAME="Wallpaper-Explorer-v$VERSION.dmg"
DMG_TEMP_NAME="temp_$DMG_NAME"
VOLUME_NAME="Wallpaper Explorer"
DMG_SIZE="200m"

# 清理之前的临时文件
rm -f "$OUTPUT_DIR/$DMG_TEMP_NAME"
rm -f "$OUTPUT_DIR/$DMG_NAME"

print_step "创建 DMG 镜像..."

# 创建临时 DMG
hdiutil create -size "$DMG_SIZE" -fs HFS+ -volname "$VOLUME_NAME" "$OUTPUT_DIR/$DMG_TEMP_NAME"

# 挂载 DMG
print_step "挂载 DMG 进行配置..."
mount_info=$(hdiutil attach "$OUTPUT_DIR/$DMG_TEMP_NAME" -readwrite -noverify)
mount_point=$(echo "$mount_info" | grep "/Volumes" | tail -1 | sed 's/.*\(\/Volumes\/.*\)/\1/')

if [ -z "$mount_point" ]; then
    print_error "无法挂载 DMG"
    echo "挂载信息: $mount_info"
    exit 1
fi

print_step "DMG 挂载点: $mount_point"

# 复制 App Bundle
print_step "复制应用程序..."
cp -R "$APP_DIR" "$mount_point/"

# 创建 Applications 文件夹的符号链接
print_step "创建 Applications 链接..."
ln -s /Applications "$mount_point/Applications"

# 创建背景图片目录（隐藏）
mkdir -p "$mount_point/.background"

# 创建简单的背景图片（如果没有的话）
if [ ! -f "$PLATFORM_DIR/background.png" ]; then
    print_step "创建安装背景..."
    # 使用 sips 创建一个简单的背景
    sips -s dpiHeight 72.0 -s dpiWidth 72.0 \
         --setProperty format png \
         --cropToHeightWidth 400 600 \
         /System/Library/Desktop\ Pictures/Solid\ Colors/Stone.png \
         "$mount_point/.background/background.png" 2>/dev/null || true
else
    cp "$PLATFORM_DIR/background.png" "$mount_point/.background/"
fi

# 使用 AppleScript 设置 DMG 窗口外观
print_step "配置 DMG 窗口外观..."
osascript << EOF
try
    tell application "Finder"
        tell disk "$VOLUME_NAME"
            open
            set current view of container window to icon view
            set toolbar visible of container window to false
            set statusbar visible of container window to false
            set the bounds of container window to {400, 100, 1000, 500}
            set theViewOptions to the icon view options of container window
            set arrangement of theViewOptions to not arranged
            set icon size of theViewOptions to 100
            
            -- 等待文件系统同步
            delay 2
            
            close
        end tell
    end tell
on error errMsg
    display dialog "AppleScript error: " & errMsg
end try
EOF

# 确保更改被写入
sync

# 卸载 DMG
print_step "卸载临时 DMG..."
hdiutil detach "$mount_point"

# 转换为只读压缩格式
print_step "压缩 DMG 镜像..."
hdiutil convert "$OUTPUT_DIR/$DMG_TEMP_NAME" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$OUTPUT_DIR/$DMG_NAME"

# 清理临时文件
rm "$OUTPUT_DIR/$DMG_TEMP_NAME"

# 验证 DMG
print_step "验证 DMG..."
hdiutil verify "$OUTPUT_DIR/$DMG_NAME"

# 创建构建信息
cat > "$OUTPUT_DIR/DMG_INFO.txt" << EOF
Wallpaper Explorer - macOS DMG 安装镜像
构建版本: v$VERSION-$(date +%Y%m%d)
构建时间: $(date '+%Y-%m-%d %H:%M:%S')
镜像类型: DMG 安装程序
目标平台: macOS 10.15+ (Intel/Apple Silicon)
构建方式: hdiutil + AppleScript 界面配置

安装说明:
1. 双击打开 DMG 文件
2. 将 Wallpaper Explorer 拖拽到 Applications 文件夹
3. 从 Applications 启动应用程序

产物说明:
- $DMG_NAME - DMG 安装镜像 (压缩格式)
EOF

# 显示结果
print_step "构建产物:"
if [ -f "$OUTPUT_DIR/$DMG_NAME" ]; then
    dmg_size=$(get_human_file_size "$OUTPUT_DIR/$DMG_NAME")
    print_success "DMG 镜像: $DMG_NAME ($dmg_size)"
    print_success "包含拖拽安装界面: App → Applications"
fi

end_timer
print_success "macOS DMG 安装镜像构建完成" 