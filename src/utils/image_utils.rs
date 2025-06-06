use std::path::Path;
use image::ImageFormat;
use crate::Result;

/// 支持的图像格式列表
pub const SUPPORTED_FORMATS: &[&str] = &[
    "jpg", "jpeg", "png", "bmp", "gif", "webp", "tiff", "tga", "ico"
];

/// 检查文件是否为支持的图像格式
pub fn is_supported_image_format(path: &Path) -> bool {
    if let Some(extension) = path.extension() {
        if let Some(ext_str) = extension.to_str() {
            return SUPPORTED_FORMATS.iter()
                .any(|&format| format.eq_ignore_ascii_case(ext_str));
        }
    }
    false
}

/// 获取图像的尺寸而不完全加载图像
pub fn get_image_dimensions(path: &Path) -> Result<(u32, u32)> {
    let dimensions = image::image_dimensions(path)?;
    Ok(dimensions)
}

/// 计算保持宽高比的缩放尺寸
pub fn calculate_scaled_size(
    original_width: u32,
    original_height: u32,
    max_width: u32,
    max_height: u32,
) -> (u32, u32) {
    let width_ratio: f32 = max_width as f32 / original_width as f32;
    let height_ratio: f32 = max_height as f32 / original_height as f32;
    let ratio: f32 = width_ratio.min(height_ratio);
    
    let new_width: u32 = (original_width as f32 * ratio) as u32;
    let new_height: u32 = (original_height as f32 * ratio) as u32;
    
    (new_width.max(1), new_height.max(1))
}

/// 从文件扩展名推断图像格式
pub fn format_from_path(path: &Path) -> Option<ImageFormat> {
    path.extension()
        .and_then(|ext| ext.to_str())
        .and_then(|ext| {
            match ext.to_lowercase().as_str() {
                "jpg" | "jpeg" => Some(ImageFormat::Jpeg),
                "png" => Some(ImageFormat::Png),
                "bmp" => Some(ImageFormat::Bmp),
                "gif" => Some(ImageFormat::Gif),
                "webp" => Some(ImageFormat::WebP),
                "tiff" | "tif" => Some(ImageFormat::Tiff),
                "tga" => Some(ImageFormat::Tga),
                "ico" => Some(ImageFormat::Ico),
                _ => None,
            }
        })
}

/// 获取图像的宽高比
pub fn get_aspect_ratio(width: u32, height: u32) -> f32 {
    if height == 0 {
        0.0
    } else {
        width as f32 / height as f32
    }
}

/// 判断图像是否为风景模式（横向）
pub fn is_landscape(width: u32, height: u32) -> bool {
    width > height
}

/// 判断图像是否为肖像模式（纵向）
pub fn is_portrait(width: u32, height: u32) -> bool {
    height > width
}

/// 判断图像是否为正方形
pub fn is_square(width: u32, height: u32) -> bool {
    width == height
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[test]
    fn test_is_supported_image_format() {
        assert!(is_supported_image_format(&PathBuf::from("test.jpg")));
        assert!(is_supported_image_format(&PathBuf::from("test.PNG")));
        assert!(!is_supported_image_format(&PathBuf::from("test.txt")));
    }

    #[test]
    fn test_calculate_scaled_size() {
        let (w, h) = calculate_scaled_size(1920, 1080, 400, 300);
        assert_eq!((w, h), (400, 225));
        
        let (w, h) = calculate_scaled_size(800, 1200, 400, 300);
        assert_eq!((w, h), (200, 300));
    }

    #[test]
    fn test_aspect_ratio() {
        assert_eq!(get_aspect_ratio(1920, 1080), 1920.0 / 1080.0);
        assert_eq!(get_aspect_ratio(100, 0), 0.0);
    }

    #[test]
    fn test_orientation() {
        assert!(is_landscape(1920, 1080));
        assert!(is_portrait(1080, 1920));
        assert!(is_square(1080, 1080));
    }
} 