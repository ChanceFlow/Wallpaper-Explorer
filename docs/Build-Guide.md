# Wallpaper Explorer - 构建指南

本指南说明如何构建 Wallpaper Explorer 的不同版本。

## 📋 目录

- [系统要求](#系统要求)
- [Windows 安装程序构建](#windows-安装程序构建)
- [传统 ZIP 包构建](#传统-zip-包构建)
- [开发环境设置](#开发环境设置)
- [故障排除](#故障排除)

## 🎯 系统要求

### 开发环境
- **操作系统**: macOS, Linux, Windows (with WSL2)
- **Docker**: 20.10+ with BuildKit support
- **内存**: 至少 4GB 可用内存
- **磁盘空间**: 至少 2GB 可用空间

### 目标系统
- **Windows**: 10 或更高版本
- **架构**: x86_64 (64位)

## 🚀 Windows 安装程序构建

### 快速开始

使用我们的自动化构建脚本：

```bash
# 构建 Windows 安装程序
./scripts/build-installer.sh
```

### 手动构建

如果您需要更多控制，可以手动执行以下步骤：

```bash
# 1. 构建 Docker 镜像
docker build -t wallpaper-installer-builder .

# 2. 运行容器生成安装程序
docker run --rm -v $(pwd)/dist:/app/dist wallpaper-installer-builder

# 3. 检查输出
ls -la dist/
```

### 构建产物

成功构建后，您将在 `dist/` 目录中找到：

- `Wallpaper-Explorer-Setup-v0.1.0.exe` - Windows 安装程序 (~11MB)
- `INSTALLER_INFO.txt` - 构建信息文件

### 安装程序特性

✅ **现代化界面** - 支持中文和英文  
✅ **智能安装** - 自动检测已安装版本  
✅ **快捷方式** - 创建桌面和开始菜单快捷方式  
✅ **完整卸载** - 包含完整的卸载功能  
✅ **注册表集成** - 正确的 Windows 集成  

## 📦 传统 ZIP 包构建

如果您需要传统的 ZIP 包分发：

```bash
# 使用 Docker Compose
docker-compose up windows-build

# 或者使用 cargo 直接构建
cargo build --release --target x86_64-pc-windows-gnu
```

## 🛠 开发环境设置

### 本地开发

```bash
# 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 添加 Windows 目标
rustup target add x86_64-pc-windows-gnu

# 安装交叉编译工具 (Ubuntu/Debian)
sudo apt-get install gcc-mingw-w64-x86-64

# 安装交叉编译工具 (macOS)
brew install mingw-w64

# 本地构建
cargo build --release
```

### Docker 开发

```bash
# 构建开发镜像
docker build -t wallpaper-dev .

# 运行开发容器
docker run -it --rm -v $(pwd):/app wallpaper-dev bash
```

## 🔧 故障排除

### 常见问题

**Q: Docker 构建失败，提示权限错误**
```bash
# 确保 Docker 有足够权限
sudo usermod -aG docker $USER
# 重新登录或重启
```

**Q: 构建时间过长**
```bash
# 使用 BuildKit 加速
export DOCKER_BUILDKIT=1
```

**Q: 内存不足错误**
```bash
# 增加 Docker 内存限制到至少 4GB
# 在 Docker Desktop 设置中调整
```

**Q: Windows 安装程序无法运行**
- 确保在 Windows 10+ 系统上运行
- 以管理员权限运行安装程序
- 检查 Windows Defender 是否阻止了文件

### 清理构建缓存

```bash
# 清理 Docker 缓存
docker system prune -a

# 清理 Cargo 缓存
cargo clean

# 清理输出目录
rm -rf dist/
```

### 调试构建

```bash
# 启用详细输出
RUST_LOG=debug ./scripts/build-installer.sh

# 检查 Docker 镜像
docker images | grep wallpaper

# 检查容器日志
docker logs <container-id>
```

## 📊 构建统计

| 构建类型 | 大小 | 构建时间 | 特性 |
|---------|------|----------|------|
| Windows 安装程序 | ~11MB | ~5分钟 | 完整安装/卸载 |
| ZIP 包 | ~28MB | ~3分钟 | 便携版本 |
| 开发版本 | ~25MB | ~2分钟 | 调试信息 |

## 🚀 CI/CD 集成

### GitHub Actions

```yaml
name: Build Windows Installer
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Windows Installer
        run: ./scripts/build-installer.sh
      - name: Upload Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: windows-installer
          path: dist/
```

### GitLab CI

```yaml
build-installer:
  image: docker:latest
  services:
    - docker:dind
  script:
    - ./scripts/build-installer.sh
  artifacts:
    paths:
      - dist/
```

## 📝 更新日志

### v0.1.0 (2025-06-06)
- ✅ 添加 Windows 安装程序支持
- ✅ 使用 NSIS 创建专业安装程序
- ✅ 支持中英文界面
- ✅ Docker 化构建流程
- ✅ 自动化构建脚本

---

如果您遇到任何问题，请查看 [故障排除](#故障排除) 部分或提交 Issue。 