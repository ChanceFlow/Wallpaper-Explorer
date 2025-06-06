# Linux DEB 包构建镜像
# 使用 Docker 构建 DEB 包

# ===================================
# 阶段1: 构建 Linux 版本
# ===================================
FROM rust:1.85-slim AS builder

# 安装基础构建工具
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

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
    cargo build --release && \
    rm -rf src

# 现在复制实际的项目文件
COPY src/ ./src/
COPY assets/ ./assets/

# 构建 Linux 版本
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build --release && \
    cp target/release/Wallpaper-Explorer ./

# ===================================
# 阶段2: 创建 DEB 包
# ===================================
FROM debian:12-slim AS packager

# 使用 Debian 稳定版，安装必要工具
RUN apt-get update && apt-get install -y \
    dpkg-dev \
    fakeroot \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /deb

# 复制构建产物和资源
COPY --from=builder /app/Wallpaper-Explorer ./
COPY --from=builder /app/assets/ ./assets/

# 复制许可证和说明文件
COPY LICENSE README.md ./

# 复制构建脚本
COPY build/platforms/linux/docker/scripts/ ./scripts/

# 设置执行权限
RUN chmod +x scripts/*.sh
RUN chmod +x Wallpaper-Explorer

# 设置环境变量
ENV PROJECT_NAME="Wallpaper Explorer"

CMD ["./scripts/create-deb.sh"] 