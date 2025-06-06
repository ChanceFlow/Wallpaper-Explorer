# 项目结构说明

## 📁 目录结构

```
Wallpaper-Explorer/
├── 📁 src/                     # 源代码目录
│   ├── 📄 lib.rs               # 库入口点，定义公共模块
│   ├── 📄 main.rs              # 应用程序入口点
│   ├── 📄 app.rs               # 主应用程序管理器
│   ├── 📄 error.rs             # 统一错误处理
│   ├── 📄 config.rs            # 配置管理
│   │
│   ├── 📁 models/              # 数据模型
│   │   ├── 📄 mod.rs           # 模块入口
│   │   └── 📄 wallpaper.rs     # 壁纸数据模型
│   │
│   ├── 📁 services/            # 业务逻辑服务
│   │   ├── 📄 mod.rs           # 模块入口
│   │   ├── 📄 wallpaper_service.rs    # 壁纸扫描和管理
│   │   └── 📄 thumbnail_service.rs    # 缩略图生成和缓存
│   │
│   ├── 📁 ui/                  # 用户界面
│   │   ├── 📄 mod.rs           # 模块入口
│   │   ├── 📄 main_window.rs   # 主窗口包装器
│   │   └── 📄 app-window.slint # Slint UI定义
│   │
│   ├── 📁 components/          # 可复用组件
│   │   ├── 📄 mod.rs           # 模块入口
│   │   └── 📄 wallpaper_grid.rs # 壁纸网格组件
│   │
│   └── 📁 utils/               # 工具函数
│       ├── 📄 mod.rs           # 模块入口
│       ├── 📄 file_utils.rs    # 文件操作工具
│       └── 📄 image_utils.rs   # 图像处理工具
│
├── 📁 tests/                   # 测试目录
│   └── 📄 integration_tests.rs # 集成测试
│
├── 📁 docs/                    # 文档目录
│   ├── 📄 ARCHITECTURE.md      # 架构文档
│   └── 📄 PROJECT_STRUCTURE.md # 项目结构说明
│
├── 📁 scripts/                 # 脚本目录
│   ├── 📄 dev.sh               # 开发环境脚本
│   └── 📄 build.sh             # 构建脚本
│
├── 📁 assets/                  # 资源文件（保留）
│   ├── 📁 fonts/
│   ├── 📁 icons/
│   └── 📁 images/
│
├── 📄 Cargo.toml               # Rust 项目配置
├── 📄 Cargo.lock               # 依赖锁定文件
├── 📄 build.rs                 # 构建脚本
├── 📄 README.md                # 项目说明
└── 📄 LICENSE                  # 许可证文件
```

## 🏗️ 架构层次

### 1. 应用层 (Application Layer)
- `src/main.rs` - 应用程序入口
- `src/app.rs` - 主应用程序管理器

### 2. 用户界面层 (UI Layer)
- `src/ui/` - UI 相关代码
- `src/components/` - 可复用的UI组件

### 3. 服务层 (Service Layer)
- `src/services/` - 业务逻辑处理

### 4. 数据层 (Data Layer)
- `src/models/` - 数据模型定义

### 5. 工具层 (Utility Layer)
- `src/utils/` - 通用工具函数
- `src/config.rs` - 配置管理
- `src/error.rs` - 错误处理

## 📋 文件说明

### 核心文件

| 文件 | 作用 | 依赖关系 |
|------|------|----------|
| `lib.rs` | 库入口，定义公共API | 所有模块 |
| `main.rs` | 应用入口，初始化应用 | `app.rs` |
| `app.rs` | 应用管理器，协调各组件 | `config.rs`, `services/`, `ui/` |
| `error.rs` | 统一错误处理 | 无 |
| `config.rs` | 配置管理 | `error.rs` |

### 模型文件

| 文件 | 作用 |
|------|------|
| `models/wallpaper.rs` | 壁纸数据模型，包含壁纸的所有属性 |

### 服务文件

| 文件 | 作用 | 依赖 |
|------|------|------|
| `services/wallpaper_service.rs` | 壁纸扫描、管理服务 | `models/`, `config.rs` |
| `services/thumbnail_service.rs` | 缩略图生成和缓存服务 | `config.rs` |

### UI文件

| 文件 | 作用 | 依赖 |
|------|------|------|
| `ui/main_window.rs` | 主窗口Rust包装器 | `error.rs` |
| `ui/app-window.slint` | Slint UI定义文件 | 无 |

### 组件文件

| 文件 | 作用 | 依赖 |
|------|------|------|
| `components/wallpaper_grid.rs` | 壁纸网格布局组件 | `models/` |

### 工具文件

| 文件 | 作用 | 依赖 |
|------|------|------|
| `utils/file_utils.rs` | 文件操作工具函数 | `error.rs` |
| `utils/image_utils.rs` | 图像处理工具函数 | `error.rs` |

## 🔄 数据流向

```
用户操作 → UI层 → 应用管理器 → 服务层 → 数据层
    ↑                                      ↓
    ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ←
```

## 🧪 测试结构

- `tests/integration_tests.rs` - 集成测试
- 各模块内的 `#[cfg(test)]` - 单元测试

## 📦 构建产物

- `target/debug/` - 调试版本
- `target/release/` - 发布版本
- 缓存目录（用户配置目录下）

## 🔧 开发工具

- `scripts/dev.sh` - 开发环境启动脚本
- `scripts/build.sh` - 构建脚本
- `build.rs` - Slint UI 编译脚本 