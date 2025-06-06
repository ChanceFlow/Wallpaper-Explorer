# Wallpaper Explorer 架构文档

## 项目概述

Wallpaper Explorer 是一个使用 Rust 和 Slint GUI 框架开发的桌面壁纸管理应用程序。

## 架构设计

### 模块结构

```
src/
├── lib.rs              # 库入口点，定义公共API
├── main.rs             # 应用程序入口点
├── app.rs              # 主应用程序管理器
├── error.rs            # 统一错误处理
├── config.rs           # 配置管理
├── models/             # 数据模型
│   ├── mod.rs
│   └── wallpaper.rs    # 壁纸数据模型
├── services/           # 业务逻辑服务
│   ├── mod.rs
│   ├── wallpaper_service.rs    # 壁纸扫描和管理
│   └── thumbnail_service.rs    # 缩略图生成和缓存
├── ui/                 # 用户界面
│   ├── mod.rs
│   ├── main_window.rs  # 主窗口包装器
│   └── app-window.slint # Slint UI定义
├── components/         # 可复用组件
│   ├── mod.rs
│   └── wallpaper_grid.rs # 壁纸网格组件
└── utils/              # 工具函数
    ├── mod.rs
    ├── file_utils.rs   # 文件操作工具
    └── image_utils.rs  # 图像处理工具
```

### 设计原则

1. **分层架构**: 清晰的分层结构，UI层、服务层、数据层分离
2. **错误处理**: 统一的错误处理机制，使用自定义错误类型
3. **配置管理**: 集中的配置管理，支持用户自定义
4. **模块化**: 高内聚、低耦合的模块设计
5. **可测试性**: 每个模块都有对应的单元测试

### 数据流

1. **应用启动**: App::new() -> 加载配置 -> 初始化服务 -> 创建UI
2. **壁纸扫描**: WallpaperService::scan_wallpapers() -> 遍历目录 -> 生成缩略图 -> 更新UI
3. **用户交互**: UI事件 -> 事件处理器 -> 服务层处理 -> 更新UI状态

### 依赖关系

- **UI层** 依赖 **服务层** 和 **模型层**
- **服务层** 依赖 **模型层** 和 **工具层**
- **模型层** 独立，不依赖其他层
- **工具层** 独立，提供通用功能

## 技术栈

- **Rust**: 系统编程语言，提供内存安全和高性能
- **Slint**: 现代GUI框架，支持声明式UI设计
- **image**: 图像处理库
- **walkdir**: 目录遍历库
- **serde**: 序列化/反序列化库
- **chrono**: 日期时间处理库

## 扩展性

该架构设计支持以下扩展：

1. **新的图像格式**: 在 `image_utils.rs` 中添加支持
2. **新的服务**: 在 `services/` 目录下添加新模块
3. **新的UI组件**: 在 `components/` 目录下添加新组件
4. **新的数据模型**: 在 `models/` 目录下添加新模型 