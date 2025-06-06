#!/bin/bash

# macOS App Bundle 构建脚本

set -e

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
PLATFORM_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$PROJECT_ROOT/dist/macos"

source "$PROJECT_ROOT/build/scripts/common.sh"

print_header "构建 macOS App Bundle"

start_timer

# 创建输出目录
ensure_directory "$OUTPUT_DIR"

# 检查 macOS 环境
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "macOS App Bundle 只能在 macOS 系统上构建"
    exit 1
fi

# 检查 Rust 环境
check_rust_env

# 切换到项目根目录
cd "$PROJECT_ROOT"

# 构建 macOS 版本
print_step "构建 macOS 可执行文件..."
cargo_build ""

# 检查构建产物
BINARY_PATH="target/release/Wallpaper-Explorer"
check_file "$BINARY_PATH"

# 创建 App Bundle 结构
APP_NAME="Wallpaper Explorer.app"
APP_DIR="$OUTPUT_DIR/$APP_NAME"
ensure_directory "$APP_DIR/Contents/MacOS"
ensure_directory "$APP_DIR/Contents/Resources"

# 复制二进制文件
print_step "创建 App Bundle..."
cp "$BINARY_PATH" "$APP_DIR/Contents/MacOS/Wallpaper Explorer"
chmod +x "$APP_DIR/Contents/MacOS/Wallpaper Explorer"

# 复制资源文件
cp -r assets/ "$APP_DIR/Contents/Resources/"

# 创建 Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleDisplayName</key>
    <string>Wallpaper Explorer</string>
    <key>CFBundleExecutable</key>
    <string>Wallpaper Explorer</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.wallpaper-explorer.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Wallpaper Explorer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 Wallpaper Explorer Team. All rights reserved.</string>
    <key>NSDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>jpg</string>
                <string>jpeg</string>
                <string>png</string>
                <string>gif</string>
                <string>bmp</string>
                <string>webp</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Image Files</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
        </dict>
    </array>
</dict>
</plist>
EOF

# 创建 PkgInfo
echo "APPL????" > "$APP_DIR/Contents/PkgInfo"

# 代码签名 (如果有开发者证书)
if check_macos_codesign; then
    print_step "对 App Bundle 进行代码签名..."
    if ! codesign --force --deep --sign "Developer ID Application" "$APP_DIR"; then
        print_warning "代码签名失败，继续构建未签名版本"
    else
        print_success "代码签名完成"
    fi
else
    print_warning "未找到代码签名证书，跳过签名"
fi

# 创建 DMG (如果有 create-dmg 工具)
print_step "创建 DMG 镜像..."
DMG_NAME="Wallpaper-Explorer-v$VERSION.dmg"

if check_command create-dmg; then
    create-dmg \
        --volname "Wallpaper Explorer" \
        --volicon "$APP_DIR/Contents/Resources/AppIcon.icns" \
        --window-pos 200 120 \
        --window-size 800 400 \
        --icon-size 100 \
        --icon "$APP_NAME" 200 190 \
        --hide-extension "$APP_NAME" \
        --app-drop-link 600 185 \
        "$OUTPUT_DIR/$DMG_NAME" \
        "$OUTPUT_DIR"
elif check_command hdiutil; then
    # 使用 hdiutil 创建简单的 DMG
    temp_dmg="$OUTPUT_DIR/temp.dmg"
    hdiutil create -size 100m -fs HFS+ -volname "Wallpaper Explorer" "$temp_dmg"
    
    # 挂载 DMG
    mount_point=$(hdiutil attach "$temp_dmg" | grep "/Volumes" | awk '{print $3}')
    
    # 复制 App Bundle
    cp -R "$APP_DIR" "$mount_point/"
    
    # 卸载并压缩
    hdiutil detach "$mount_point"
    hdiutil convert "$temp_dmg" -format UDZO -o "$OUTPUT_DIR/$DMG_NAME"
    rm "$temp_dmg"
else
    print_warning "未找到 DMG 创建工具，跳过 DMG 创建"
    DMG_NAME=""
fi

# 创建构建信息
cat > "$OUTPUT_DIR/APP_INFO.txt" << EOF
Wallpaper Explorer - macOS App Bundle
构建版本: v$VERSION-$(date +%Y%m%d)
构建时间: $(date '+%Y-%m-%d %H:%M:%S')
包类型: macOS App Bundle
目标平台: macOS 10.15+ (Intel/Apple Silicon)
构建方式: Cargo 本地编译

产物说明:
- $APP_NAME - macOS 应用程序包
- $DMG_NAME - DMG 安装镜像
EOF

# 显示结果
print_step "构建产物:"
local app_size=$(du -sh "$APP_DIR" | cut -f1)
print_success "App Bundle: $APP_NAME ($app_size)"

if [ -n "$DMG_NAME" ] && [ -f "$OUTPUT_DIR/$DMG_NAME" ]; then
    local dmg_size=$(get_human_file_size "$OUTPUT_DIR/$DMG_NAME")
    print_success "DMG 镜像: $DMG_NAME ($dmg_size)"
fi

end_timer
print_success "macOS App Bundle 构建完成" 