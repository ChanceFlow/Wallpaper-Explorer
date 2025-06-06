# syntax=docker/dockerfile:1
# Windows 交叉编译 - 简化版本
# 专注于交叉编译功能，移除不必要的平台变量

# ===================================
# 阶段1: 构建环境
# ===================================
FROM rust:1.83-slim AS builder

# 设置工作目录
WORKDIR /app

# 安装交叉编译必需的工具
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    gcc-mingw-w64-x86-64 \
    libfontconfig1-dev \
    libfreetype6-dev \
    zip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 配置 Rust 交叉编译
RUN rustup update && \
    rustup toolchain install nightly && \
    rustup default nightly && \
    rustup target add x86_64-pc-windows-gnu

# 设置交叉编译环境变量
ENV CARGO_TARGET_X86_64_PC_WINDOWS_GNU_LINKER=x86_64-w64-mingw32-gcc
ENV CC_x86_64_pc_windows_gnu=x86_64-w64-mingw32-gcc
ENV CXX_x86_64_pc_windows_gnu=x86_64-w64-mingw32-g++
ENV PKG_CONFIG_ALLOW_CROSS=1

# 复制项目文件
COPY Cargo.toml Cargo.lock build.rs ./
COPY src/ ./src/
COPY assets/ ./assets/

# 下载依赖
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo fetch --target x86_64-pc-windows-gnu

# 构建 Windows 版本
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build --release --target x86_64-pc-windows-gnu && \
    cp target/x86_64-pc-windows-gnu/release/Wallpaper-Explorer.exe ./

# ===================================
# 阶段2: 打包环境
# ===================================
FROM alpine:3.19 AS packager

RUN apk add --no-cache zip
WORKDIR /package

# 复制构建产物
COPY --from=builder /app/Wallpaper-Explorer.exe ./Wallpaper-Explorer.exe
COPY --from=builder /app/assets/ ./assets/

# 创建打包脚本
RUN echo '#!/bin/sh' > /package/build.sh && \
    echo 'set -e' >> /package/build.sh && \
    echo 'echo "🚀 开始打包 Windows 版本..."' >> /package/build.sh && \
    echo 'VERSION=$(date +"%Y%m%d")' >> /package/build.sh && \
    echo 'BUILD_DATE=$(date "+%Y-%m-%d %H:%M:%S UTC")' >> /package/build.sh && \
    echo 'echo "Wallpaper Explorer - Windows 版本" > VERSION.txt' >> /package/build.sh && \
    echo 'echo "构建版本: v0.1.0-$VERSION" >> VERSION.txt' >> /package/build.sh && \
    echo 'echo "构建时间: $BUILD_DATE" >> VERSION.txt' >> /package/build.sh && \
    echo 'echo "目标平台: Windows x86_64" >> VERSION.txt' >> /package/build.sh && \
    echo 'echo "构建方式: Docker 交叉编译" >> VERSION.txt' >> /package/build.sh && \
    echo 'echo "# Wallpaper Explorer - Windows 版本" > README.txt' >> /package/build.sh && \
    echo 'echo "" >> README.txt' >> /package/build.sh && \
    echo 'echo "## 运行方法" >> README.txt' >> /package/build.sh && \
    echo 'echo "双击 Wallpaper-Explorer.exe 即可运行" >> README.txt' >> /package/build.sh && \
    echo 'echo "" >> README.txt' >> /package/build.sh && \
    echo 'echo "## 系统要求" >> README.txt' >> /package/build.sh && \
    echo 'echo "- Windows 10 或更高版本" >> README.txt' >> /package/build.sh && \
    echo 'echo "- 64位操作系统" >> README.txt' >> /package/build.sh && \
    echo 'ZIP_NAME="Wallpaper-Explorer-Windows-v0.1.0.zip"' >> /package/build.sh && \
    echo 'mkdir -p /app/dist' >> /package/build.sh && \
    echo 'zip -r "/app/dist/$ZIP_NAME" . -x "*.sh"' >> /package/build.sh && \
    echo 'mkdir -p "/app/dist/Wallpaper-Explorer"' >> /package/build.sh && \
    echo 'cp -r * "/app/dist/Wallpaper-Explorer/" 2>/dev/null || true' >> /package/build.sh && \
    echo 'rm -f "/app/dist/Wallpaper-Explorer"/*.sh 2>/dev/null || true' >> /package/build.sh && \
    echo 'echo "✅ 构建完成！"' >> /package/build.sh && \
    echo 'echo "📦 输出文件："' >> /package/build.sh && \
    echo 'echo "   - $ZIP_NAME"' >> /package/build.sh && \
    echo 'echo "   - Wallpaper-Explorer/ (解压版本)"' >> /package/build.sh && \
    echo 'ls -la /app/dist/' >> /package/build.sh && \
    chmod +x /package/build.sh

CMD ["/package/build.sh"] 