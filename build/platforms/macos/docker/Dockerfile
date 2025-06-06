# macOS App Bundle 构建镜像
# 使用 Docker 交叉编译构建 macOS 应用

# ===================================
# 阶段1: 构建 macOS 版本
# ===================================
FROM rust:1.85 AS builder

# 安装交叉编译工具和依赖
RUN apt-get update && apt-get install -y \
    clang \
    llvm \
    gcc \
    libc6-dev \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 添加 macOS 目标
RUN rustup target add x86_64-apple-darwin
RUN rustup target add aarch64-apple-darwin

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

# 编译依赖（针对 x86_64）
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo build --release --target x86_64-apple-darwin && \
    rm -rf src

# 现在复制实际的项目文件
COPY src/ ./src/
COPY assets/ ./assets/

# 设置交叉编译环境变量
ENV CC_x86_64_apple_darwin=clang
ENV CXX_x86_64_apple_darwin=clang++
ENV AR_x86_64_apple_darwin=ar
ENV CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER=clang

# 构建 macOS 版本（Intel）
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build --release --target x86_64-apple-darwin && \
    cp target/x86_64-apple-darwin/release/Wallpaper-Explorer ./Wallpaper-Explorer-x86_64

# ===================================
# 阶段2: 创建 App Bundle
# ===================================
FROM ubuntu:22.04 AS packager

# 安装必要的工具
RUN apt-get update && apt-get install -y \
    zip \
    tree \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 复制构建产物和资源
COPY --from=builder /app/Wallpaper-Explorer-x86_64 ./
COPY --from=builder /app/assets/ ./assets/

# 复制许可证和说明文件
COPY LICENSE README.md ./

# 复制构建脚本
COPY build/platforms/macos/docker/scripts/ ./scripts/

# 设置执行权限
RUN chmod +x scripts/*.sh
RUN chmod +x Wallpaper-Explorer-x86_64

# 设置环境变量
ENV PROJECT_NAME="Wallpaper Explorer"

CMD ["./scripts/create-app.sh"] 