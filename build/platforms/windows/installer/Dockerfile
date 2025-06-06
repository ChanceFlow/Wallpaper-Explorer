# Windows 安装程序构建镜像
# 使用 NSIS 创建专业的 Windows 安装程序

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

# 复制项目文件
COPY Cargo.toml Cargo.lock build.rs ./
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
# 阶段2: 创建安装程序
# ===================================
FROM ubuntu:22.04 AS installer

# 安装必要的工具
RUN apt-get update && apt-get install -y \
    nsis \
    nsis-pluginapi \
    nsis-doc \
    zip \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /installer

# 复制构建产物和资源
COPY --from=builder /app/Wallpaper-Explorer.exe ./
COPY --from=builder /app/assets/ ./assets/

# 复制安装程序配置
COPY build/platforms/windows/installer/nsis/ ./nsis/

# 复制构建脚本
COPY build/platforms/windows/installer/scripts/ ./scripts/

# 复制许可证文件
COPY LICENSE ./license.txt

# 设置执行权限
RUN chmod +x scripts/*.sh

# 设置环境变量
ENV PROJECT_NAME="Wallpaper Explorer"
ENV VERSION="0.1.0"

CMD ["./scripts/build-installer.sh"] 