use std::fmt;

pub type Result<T> = std::result::Result<T, WallpaperError>;

#[derive(Debug)]
pub enum WallpaperError {
    Io(std::io::Error),
    Image(image::error::ImageError),
    Slint(slint::PlatformError),
    Config(String),
    Service(String),
}

impl fmt::Display for WallpaperError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            WallpaperError::Io(err) => write!(f, "IO错误: {}", err),
            WallpaperError::Image(err) => write!(f, "图像处理错误: {}", err),
            WallpaperError::Slint(err) => write!(f, "UI错误: {}", err),
            WallpaperError::Config(msg) => write!(f, "配置错误: {}", msg),
            WallpaperError::Service(msg) => write!(f, "服务错误: {}", msg),
        }
    }
}

impl std::error::Error for WallpaperError {}

impl From<std::io::Error> for WallpaperError {
    fn from(err: std::io::Error) -> Self {
        WallpaperError::Io(err)
    }
}

impl From<image::error::ImageError> for WallpaperError {
    fn from(err: image::error::ImageError) -> Self {
        WallpaperError::Image(err)
    }
}

impl From<slint::PlatformError> for WallpaperError {
    fn from(err: slint::PlatformError) -> Self {
        WallpaperError::Slint(err)
    }
} 