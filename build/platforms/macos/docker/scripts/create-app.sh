#!/bin/bash
set -e

echo "🚀 开始构建 macOS App Bundle..."

# 显示文件列表
echo "📁 当前目录文件:"
ls -la

# 确保输出目录存在
mkdir -p /app/output

# 创建 App Bundle 结构
APP_NAME="Wallpaper Explorer.app"
APP_DIR="/app/output/$APP_NAME"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

echo "📦 创建 App Bundle..."

# 复制二进制文件
cp Wallpaper-Explorer-x86_64 "$APP_DIR/Contents/MacOS/Wallpaper Explorer"
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

# 创建 ZIP 包
echo "📦 创建 ZIP 包..."
cd /app/output
ZIP_NAME="Wallpaper-Explorer-macOS-v$VERSION.zip"
zip -r "$ZIP_NAME" "$APP_NAME"

# 创建构建信息文件
cat > "/app/output/APP_INFO.txt" << EOF
Wallpaper Explorer - macOS App Bundle
构建版本: v$VERSION-$(date +%Y%m%d)
构建时间: $(date '+%Y-%m-%d %H:%M:%S UTC')
包类型: macOS App Bundle
目标平台: macOS 10.15+ (Intel x86_64)
构建方式: Docker 交叉编译

产物说明:
- $APP_NAME - macOS 应用程序包
- $ZIP_NAME - macOS 应用 ZIP 包

注意: 此版本通过 Docker 交叉编译构建，未进行代码签名
在真正的 macOS 系统上可能需要允许未签名应用运行
EOF

# 检查构建结果
if [ -f "/app/output/$ZIP_NAME" ]; then
    echo "✅ macOS App Bundle 构建成功！"
    
    # 显示文件信息
    echo "📊 App Bundle 信息:"
    ls -lh "/app/output/$ZIP_NAME"
    du -sh "/app/output/$APP_NAME"
    
    echo "🎉 构建完成！App Bundle 已保存到: /app/output/"
else
    echo "❌ App Bundle 构建失败"
    exit 1
fi 