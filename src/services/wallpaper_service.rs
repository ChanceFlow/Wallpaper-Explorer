use std::path::{Path, PathBuf};
use walkdir::WalkDir;
use crate::{Result, WallpaperError};
use crate::config::Config;
use crate::models::Wallpaper;
use crate::services::ThumbnailService;

pub struct WallpaperService {
    config: Config,
    thumbnail_service: ThumbnailService,
    wallpapers: Vec<Wallpaper>,
}

impl WallpaperService {
    pub fn new(config: &Config) -> Result<Self> {
        let thumbnail_service: ThumbnailService = ThumbnailService::new(config)?;
        
        Ok(Self {
            config: config.clone(),
            thumbnail_service,
            wallpapers: Vec::new(),
        })
    }
    
    pub fn scan_wallpapers(&mut self) -> Result<()> {
        log::info!("开始扫描壁纸目录...");
        self.wallpapers.clear();
        
        // 克隆目录列表以避免借用冲突
        let directories = self.config.wallpaper_directories.clone();
        for directory in &directories {
            if directory.exists() {
                self.scan_directory(directory)?;
            } else {
                log::warn!("目录不存在: {:?}", directory);
            }
        }
        
        log::info!("扫描完成，找到 {} 张壁纸", self.wallpapers.len());
        Ok(())
    }
    
    fn scan_directory(&mut self, directory: &Path) -> Result<()> {
        let walker = WalkDir::new(directory)
            .follow_links(true)
            .max_depth(5); // 限制递归深度
        
        for entry in walker {
            let entry = entry.map_err(|e| {
                WallpaperError::Service(format!("遍历目录时出错: {}", e))
            })?;
            
            let path: PathBuf = entry.path().to_path_buf();
            
            if path.is_file() && self.config.is_supported_format(&path) {
                match self.process_wallpaper_file(path) {
                    Ok(wallpaper) => {
                        self.wallpapers.push(wallpaper);
                    }
                    Err(e) => {
                        log::warn!("处理文件失败 {:?}: {}", entry.path(), e);
                    }
                }
            }
        }
        
        Ok(())
    }
    
    fn process_wallpaper_file(&mut self, path: PathBuf) -> Result<Wallpaper> {
        log::debug!("处理壁纸文件: {:?}", path);
        
        // 创建壁纸模型
        let mut wallpaper: Wallpaper = Wallpaper::new(path.clone())
            .map_err(|e| WallpaperError::Service(format!("创建壁纸模型失败: {}", e)))?;
        
        // 获取图片尺寸
        if let Ok(dimensions) = image::image_dimensions(&path) {
            wallpaper = wallpaper.with_dimensions(dimensions.0, dimensions.1);
        }
        
        // 生成缩略图
        if let Ok(thumbnail_path) = self.thumbnail_service.generate_thumbnail(&path) {
            wallpaper = wallpaper.with_thumbnail(thumbnail_path);
        }
        
        Ok(wallpaper)
    }
    
    pub fn get_wallpapers(&self) -> &[Wallpaper] {
        &self.wallpapers
    }
    
    pub fn get_wallpaper_by_id(&self, id: &str) -> Option<&Wallpaper> {
        self.wallpapers.iter().find(|w| w.id == id)
    }
    
    pub fn filter_by_format(&self, format: &str) -> Vec<&Wallpaper> {
        self.wallpapers
            .iter()
            .filter(|w| w.format.eq_ignore_ascii_case(format))
            .collect()
    }
    
    pub fn filter_by_size(&self, min_width: u32, min_height: u32) -> Vec<&Wallpaper> {
        self.wallpapers
            .iter()
            .filter(|w| w.size.0 >= min_width && w.size.1 >= min_height)
            .collect()
    }
} 