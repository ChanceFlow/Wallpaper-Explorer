# Wallpaper Explorer

一个使用 Rust 和 Slint GUI 框架开发的现代化桌面壁纸管理应用程序。

## 🌟 特性

- 🖼️ **智能壁纸浏览**: 快速扫描和浏览本地壁纸收藏
- 🔍 **高效搜索**: 支持按格式、尺寸、标签等多种方式筛选
- ⚡ **缩略图缓存**: 智能缓存系统，提供流畅的浏览体验
- 🎨 **现代化UI**: 基于 Slint 框架的美观用户界面
- 🔧 **可配置**: 支持自定义扫描目录、缓存设置等
- 🚀 **高性能**: Rust 语言保证的内存安全和高性能

## 📋 系统要求

- **操作系统**: Windows 10+, macOS 10.15+, Linux (Ubuntu 18.04+)
- **内存**: 最少 512MB RAM
- **存储**: 50MB 可用空间（不包括壁纸缓存）

## 🚀 快速开始

### 安装 Rust 开发环境

```bash
# 安装 Rust (如果尚未安装)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

### 克隆和构建

```bash
# 克隆仓库
git clone https://github.com/your-username/Wallpaper-Explorer.git
cd Wallpaper-Explorer

# 开发模式运行
./scripts/dev.sh

# 或者手动构建
cargo build --release
```

## 🏗️ 项目架构

```
src/
├── lib.rs              # 库入口点
├── main.rs             # 应用程序入口
├── app.rs              # 主应用程序管理器
├── error.rs            # 统一错误处理
├── config.rs           # 配置管理
├── models/             # 数据模型
├── services/           # 业务逻辑服务
├── ui/                 # 用户界面
├── components/         # 可复用组件
└── utils/              # 工具函数
```

详细架构说明请参考 [架构文档](docs/ARCHITECTURE.md)。

## 🛠️ 开发

### 开发环境设置

```bash
# 安装依赖并运行测试
cargo test

# 开发模式运行（带调试日志）
RUST_LOG=debug cargo run

# 使用开发脚本
./scripts/dev.sh
```

### 构建发布版本

```bash
# 使用构建脚本
./scripts/build.sh

# 或手动构建
cargo build --release
```

### 代码规范

- 使用 `cargo fmt` 格式化代码
- 使用 `cargo clippy` 进行代码检查
- 所有公共 API 必须有文档注释
- 新功能需要添加相应的单元测试

## 📦 依赖项

主要依赖：

- **slint**: 现代 GUI 框架
- **image**: 图像处理库
- **walkdir**: 目录遍历
- **serde**: 序列化/反序列化
- **chrono**: 日期时间处理
- **env_logger**: 日志记录

开发依赖：

- **dirs**: 系统目录获取
- **toml**: TOML 配置文件解析

## 🤝 贡献

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [Slint](https://slint-ui.com/) - 优秀的 Rust GUI 框架
- [image-rs](https://github.com/image-rs/image) - 强大的图像处理库
- Rust 社区的所有贡献者

## 📞 联系

如有问题或建议，请通过以下方式联系：

- 提交 [Issue](https://github.com/your-username/Wallpaper-Explorer/issues)
- 发送邮件至: your-email@example.com

---

⭐ 如果这个项目对您有帮助，请给它一个星标！
