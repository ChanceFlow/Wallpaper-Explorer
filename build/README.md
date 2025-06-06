# Wallpaper Explorer - 多平台构建系统

这是 Wallpaper Explorer 项目的多平台构建系统，支持 Windows、Linux、macOS 等多个平台的不同打包格式。

## 📁 目录结构

```
build/
├── platforms/           # 平台特定的构建配置
│   ├── windows/         # Windows 平台
│   │   ├── installer/   # NSIS 安装程序
│   │   ├── portable/    # 便携版 ZIP
│   │   └── docker/      # Docker 镜像
│   ├── linux/           # Linux 平台
│   │   ├── deb/         # Debian 包
│   │   ├── rpm/         # RPM 包
│   │   ├── appimage/    # AppImage
│   │   └── docker/      # Docker 镜像
│   ├── macos/           # macOS 平台
│   │   ├── dmg/         # DMG 镜像
│   │   ├── app/         # App Bundle
│   │   └── homebrew/    # Homebrew Formula
│   └── cross/           # 交叉编译
│       └── docker/      # Docker 交叉编译
├── scripts/             # 构建脚本
│   ├── build.sh         # 主构建脚本
│   ├── common.sh        # 通用函数
│   ├── clean.sh         # 清理脚本
│   └── release.sh       # 发布脚本
└── configs/             # 配置文件
    ├── cargo/           # Cargo 配置
    └── ci/              # CI/CD 配置
```

## 🚀 快速开始

### 构建 Windows 安装程序
```bash
./build/scripts/build.sh windows installer
```

### 构建 Windows 便携版
```bash
./build/scripts/build.sh windows portable
```

### 构建 Linux DEB 包
```bash
./build/scripts/build.sh linux deb
```

### 构建 macOS App Bundle
```bash
./build/scripts/build.sh macos app
```

### 构建所有平台
```bash
./build/scripts/build.sh all
```

## 📋 支持的平台和格式

### Windows
- **installer**: NSIS 安装程序 (.exe)
- **portable**: 便携版 ZIP 包
- **docker**: Docker 镜像

### Linux
- **deb**: Debian/Ubuntu 包 (.deb)
- **rpm**: Red Hat/Fedora 包 (.rpm)
- **appimage**: AppImage 可执行文件
- **docker**: Docker 镜像

### macOS
- **dmg**: DMG 安装镜像
- **app**: App Bundle (.app)
- **homebrew**: Homebrew Formula

## 🛠️ 系统要求

### 基本要求
- Rust 1.85+ 
- Git
- Docker (可选，用于某些构建目标)

### Windows 交叉编译
```bash
# Ubuntu/Debian
sudo apt install gcc-mingw-w64-x86-64

# macOS
brew install mingw-w64
```

### Linux 包构建
```bash
# Debian 包
sudo apt install dpkg-dev fakeroot

# RPM 包
sudo dnf install rpm-build

# AppImage
# 下载 appimagetool
```

### macOS 构建
```bash
# 安装 create-dmg (可选)
brew install create-dmg
```

## 🔧 配置

### Cargo 配置
构建系统会自动使用 `build/configs/cargo/config.toml` 中的交叉编译配置。

### 环境变量
- `VERSION`: 构建版本 (默认从 Cargo.toml 读取)
- `PROJECT_NAME`: 项目名称
- `RELEASE_BUILD`: 是否为发布构建

## 📦 构建产物

所有构建产物都会保存在 `dist/` 目录下，按平台分类：

```
dist/
├── windows/
│   ├── Wallpaper-Explorer-Setup-v0.1.0.exe
│   ├── Wallpaper-Explorer-Portable-v0.1.0.zip
│   └── *.txt (构建信息)
├── linux/
│   ├── wallpaper-explorer_0.1.0_amd64.deb
│   ├── wallpaper-explorer-0.1.0.x86_64.rpm
│   └── *.txt (构建信息)
└── macos/
    ├── Wallpaper Explorer.app/
    ├── Wallpaper-Explorer-v0.1.0.dmg
    └── *.txt (构建信息)
```

## 🔍 故障排除

### 常见问题

1. **交叉编译失败**
   - 确保安装了对应的工具链
   - 检查环境变量设置

2. **Docker 构建失败**
   - 确保 Docker 服务运行
   - 检查 Docker BuildKit 支持

3. **权限错误**
   - 给构建脚本添加执行权限: `chmod +x build/scripts/*.sh`

### 调试模式
```bash
# 启用详细输出
./build/scripts/build.sh windows installer --verbose

# 清理后重新构建
./build/scripts/build.sh windows installer --clean
```

## 🤝 贡献

要添加新的构建目标：

1. 在 `build/platforms/` 下创建对应目录
2. 编写 `build.sh` 脚本
3. 更新主构建脚本中的平台支持
4. 添加相应的文档

## 📄 许可证

本构建系统遵循与主项目相同的许可证。 