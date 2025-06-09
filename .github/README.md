# GitHub Actions 构建说明

本项目配置了两个GitHub Actions工作流用于构建Windows x64版本的应用。

## 工作流文件

### 1. `build-windows.yml` - 发布构建
- **触发条件**: 
  - 推送到 `main` 或 `master` 分支
  - 创建以 `v` 开头的标签（如 `v1.0.0`）
  - 手动触发
- **功能**: 构建应用并创建GitHub Release，上传安装包
- **输出**: Windows安装程序（.msi 和 .exe 文件）

### 2. `test-build.yml` - 测试构建
- **触发条件**: 
  - 推送到 `main`、`master` 或 `develop` 分支
  - Pull Request
- **功能**: 仅测试构建，不创建Release
- **输出**: 构建产物作为Artifacts上传，保留7天

## 使用方法

### 发布新版本
1. 更新 `src-tauri/tauri.conf.json` 中的版本号
2. 创建并推送标签：
   ```bash
   git tag v0.1.1
   git push origin v0.1.1
   ```
3. GitHub Actions会自动构建并创建Release

### 测试构建
- 直接推送代码到主分支即可触发测试构建
- 在Actions页面可以下载构建产物

### 手动触发
1. 进入GitHub仓库的Actions页面
2. 选择"Build Windows App"工作流
3. 点击"Run workflow"

## 权限设置

确保GitHub Actions有足够的权限：
1. 进入仓库 `Settings` → `Actions` → `General`
2. 在"Workflow permissions"部分选择"Read and write permissions"

## 构建产物

### Windows x64 版本包含：
- `.msi` 安装程序（Windows Installer）
- `.exe` 安装程序（NSIS）
- 应用程序文件

### 文件位置
构建产物会保存在：
```
src-tauri/target/x86_64-pc-windows-msvc/release/bundle/
├── msi/
├── nsis/
└── ...
```