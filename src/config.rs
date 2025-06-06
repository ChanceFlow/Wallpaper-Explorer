use std::path::{Path, PathBuf};
use serde::{Deserialize, Serialize};
use crate::{Result, WallpaperError};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    pub wallpaper_directories: Vec<PathBuf>,
    pub supported_formats: Vec<String>,
    pub thumbnail_size: (u32, u32),
    pub cache_directory: PathBuf,
    pub max_cache_size_mb: u64,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            wallpaper_directories: vec![
                dirs::picture_dir().unwrap_or_else(|| PathBuf::from(".")),
            ],
            supported_formats: vec![
                "jpg".to_string(),
                "jpeg".to_string(),
                "png".to_string(),
                "bmp".to_string(),
                "gif".to_string(),
                "webp".to_string(),
            ],
            thumbnail_size: (200, 150),
            cache_directory: dirs::cache_dir()
                .unwrap_or_else(|| PathBuf::from("."))
                .join("wallpaper-explorer"),
            max_cache_size_mb: 500,
        }
    }
}

impl Config {
    pub fn load() -> Result<Self> {
        let config_path: PathBuf = Self::config_file_path()?;
        
        if config_path.exists() {
            let content: String = std::fs::read_to_string(&config_path)?;
            let config: Config = toml::from_str(&content)
                .map_err(|e| WallpaperError::Config(format!("解析配置文件失败: {}", e)))?;
            Ok(config)
        } else {
            let config: Config = Self::default();
            config.save()?;
            Ok(config)
        }
    }
    
    pub fn save(&self) -> Result<()> {
        let config_path: PathBuf = Self::config_file_path()?;
        
        if let Some(parent) = config_path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        
        let content: String = toml::to_string_pretty(self)
            .map_err(|e| WallpaperError::Config(format!("序列化配置失败: {}", e)))?;
        
        std::fs::write(&config_path, content)?;
        Ok(())
    }
    
    fn config_file_path() -> Result<PathBuf> {
        let config_dir: PathBuf = dirs::config_dir()
            .ok_or_else(|| WallpaperError::Config("无法找到配置目录".to_string()))?;
        
        Ok(config_dir.join("wallpaper-explorer").join("config.toml"))
    }
    
    pub fn is_supported_format(&self, path: &Path) -> bool {
        if let Some(extension) = path.extension() {
            if let Some(ext_str) = extension.to_str() {
                return self.supported_formats.iter()
                    .any(|format| format.eq_ignore_ascii_case(ext_str));
            }
        }
        false
    }
} 