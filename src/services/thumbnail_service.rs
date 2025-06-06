use std::path::{Path, PathBuf};
use image::{DynamicImage, ImageFormat};
use crate::Result;
use crate::config::Config;

pub struct ThumbnailService {
    cache_directory: PathBuf,
    thumbnail_size: (u32, u32),
}

impl ThumbnailService {
    pub fn new(config: &Config) -> Result<Self> {
        let cache_directory: PathBuf = config.cache_directory.join("thumbnails");
        
        // 确保缓存目录存在
        std::fs::create_dir_all(&cache_directory)?;
        
        Ok(Self {
            cache_directory,
            thumbnail_size: config.thumbnail_size,
        })
    }
    
    pub fn generate_thumbnail(&self, image_path: &Path) -> Result<PathBuf> {
        let thumbnail_path: PathBuf = self.get_thumbnail_path(image_path);
        
        // 如果缩略图已存在且比原图新，直接返回
        if self.is_thumbnail_valid(&thumbnail_path, image_path)? {
            return Ok(thumbnail_path);
        }
        
        log::debug!("为 {:?} 生成缩略图", image_path);
        
        // 加载原图
        let image: DynamicImage = image::open(image_path)?;
        
        // 计算缩略图尺寸，保持宽高比
        let (original_width, original_height) = (image.width(), image.height());
        let (thumb_width, thumb_height) = self.calculate_thumbnail_size(
            original_width, 
            original_height
        );
        
        // 生成缩略图
        let thumbnail: DynamicImage = image.resize(
            thumb_width,
            thumb_height,
            image::imageops::FilterType::Lanczos3,
        );
        
        // 确保缩略图目录存在
        if let Some(parent) = thumbnail_path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        
        // 保存缩略图
        thumbnail.save_with_format(&thumbnail_path, ImageFormat::Jpeg)?;
        
        Ok(thumbnail_path)
    }
    
    fn get_thumbnail_path(&self, image_path: &Path) -> PathBuf {
        // 使用原图路径的哈希作为缩略图文件名
        use std::hash::{Hash, Hasher};
        let mut hasher = std::collections::hash_map::DefaultHasher::new();
        image_path.hash(&mut hasher);
        let hash: u64 = hasher.finish();
        let filename: String = format!("{:x}.jpg", hash);
        
        self.cache_directory.join(filename)
    }
    
    fn is_thumbnail_valid(&self, thumbnail_path: &Path, original_path: &Path) -> Result<bool> {
        if !thumbnail_path.exists() {
            return Ok(false);
        }
        
        let thumbnail_metadata = std::fs::metadata(thumbnail_path)?;
        let original_metadata = std::fs::metadata(original_path)?;
        
        // 检查缩略图是否比原图新
        Ok(thumbnail_metadata.modified()? >= original_metadata.modified()?)
    }
    
    fn calculate_thumbnail_size(&self, original_width: u32, original_height: u32) -> (u32, u32) {
        let (max_width, max_height) = self.thumbnail_size;
        
        let width_ratio: f32 = max_width as f32 / original_width as f32;
        let height_ratio: f32 = max_height as f32 / original_height as f32;
        let ratio: f32 = width_ratio.min(height_ratio);
        
        let new_width: u32 = (original_width as f32 * ratio) as u32;
        let new_height: u32 = (original_height as f32 * ratio) as u32;
        
        (new_width.max(1), new_height.max(1))
    }
    
    pub fn clear_cache(&self) -> Result<()> {
        if self.cache_directory.exists() {
            std::fs::remove_dir_all(&self.cache_directory)?;
            std::fs::create_dir_all(&self.cache_directory)?;
        }
        Ok(())
    }
    
    pub fn get_cache_size(&self) -> Result<u64> {
        let mut total_size: u64 = 0;
        
        if self.cache_directory.exists() {
            for entry in walkdir::WalkDir::new(&self.cache_directory) {
                if let Ok(entry) = entry {
                    if entry.file_type().is_file() {
                        if let Ok(metadata) = entry.metadata() {
                            total_size += metadata.len();
                        }
                    }
                }
            }
        }
        
        Ok(total_size)
    }
} 