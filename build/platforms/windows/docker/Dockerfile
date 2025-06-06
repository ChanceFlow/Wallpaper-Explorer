# Windows 便携版构建镜像
# 使用 Docker 交叉编译创建便携版 ZIP 包

# ===================================
# 阶段1: 构建 Windows 版本
# ===================================
FROM rust:1.85 AS builder

# 安装交叉编译工具
RUN apt-get update && apt-get install -y \
    gcc-mingw-w64-x86-64 \
    && rm -rf /var/lib/apt/lists/*

# 添加 Windows 目标
RUN rustup target add x86_64-pc-windows-gnu

# 设置工作目录
WORKDIR /app

# 先复制依赖文件以利用 Docker 缓存
COPY Cargo.toml Cargo.lock ./
COPY build.rs ./

# 创建虚拟的 src 目录和 main.rs 以编译依赖
RUN mkdir -p src/ui && \
    echo "fn main() {}" > src/main.rs && \
    echo "pub mod ui;" > src/lib.rs && \
    echo "pub mod main_window;" > src/ui/mod.rs && \
    echo "pub struct MainWindow;" > src/ui/main_window.rs && \
    echo 'export component AppWindow inherits Window { title: "App"; }' > src/ui/app-window.slint

# 编译依赖（利用缓存）
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo build --release --target x86_64-pc-windows-gnu && \
    rm -rf src

# 现在复制实际的项目文件
COPY src/ ./src/
COPY assets/ ./assets/

# 设置交叉编译环境变量
ENV CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc
ENV CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++
ENV AR_x86_64_pc_windows_gnu=x86_64-w64-mingw32-ar
ENV CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc

# 构建 Windows 版本
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build --release --target x86_64-pc-windows-gnu && \
    cp target/x86_64-pc-windows-gnu/release/Wallpaper-Explorer.exe ./

# ===================================
# 阶段2: 创建便携版包
# ===================================
FROM ubuntu:22.04 AS packager

# 安装必要的工具
RUN apt-get update && apt-get install -y \
    zip \
    tree \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /portable

# 复制构建产物和资源
COPY --from=builder /app/Wallpaper-Explorer.exe ./
COPY --from=builder /app/assets/ ./assets/

# 复制许可证和说明文件
COPY LICENSE README.md ./

# 复制构建脚本
COPY build/platforms/windows/docker/scripts/ ./scripts/

# 设置执行权限
RUN chmod +x scripts/*.sh

# 设置环境变量
ENV PROJECT_NAME="Wallpaper Explorer"
# ENV VERSION="0.1.0"  # 移除硬编码版本，从运行时获取

CMD ["./scripts/create-portable.sh"] 