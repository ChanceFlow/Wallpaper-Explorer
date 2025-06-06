use std::path::PathBuf;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Wallpaper {
    pub id: String,
    pub path: PathBuf,
    pub filename: String,
    pub size: (u32, u32),
    pub file_size: u64,
    pub format: String,
    pub thumbnail_path: Option<PathBuf>,
    pub created_at: chrono::DateTime<chrono::Utc>,
    pub modified_at: chrono::DateTime<chrono::Utc>,
    pub tags: Vec<String>,
}

impl Wallpaper {
    pub fn new(path: PathBuf) -> Result<Self, Box<dyn std::error::Error>> {
        let metadata = std::fs::metadata(&path)?;
        let filename: String = path.file_name()
            .and_then(|name| name.to_str())
            .unwrap_or("unknown")
            .to_string();
        
        let format: String = path.extension()
            .and_then(|ext| ext.to_str())
            .unwrap_or("unknown")
            .to_lowercase();
        
        // 使用文件路径生成唯一ID
        use std::hash::{Hash, Hasher};
        let mut hasher = std::collections::hash_map::DefaultHasher::new();
        path.hash(&mut hasher);
        let id: String = format!("{:x}", hasher.finish());
        
        let created_at: chrono::DateTime<chrono::Utc> = metadata.created()
            .unwrap_or(std::time::SystemTime::now())
            .into();
        
        let modified_at: chrono::DateTime<chrono::Utc> = metadata.modified()
            .unwrap_or(std::time::SystemTime::now())
            .into();
        
        Ok(Self {
            id,
            path,
            filename,
            size: (0, 0), // 将在加载图片时填充
            file_size: metadata.len(),
            format,
            thumbnail_path: None,
            created_at,
            modified_at,
            tags: Vec::new(),
        })
    }
    
    pub fn with_dimensions(mut self, width: u32, height: u32) -> Self {
        self.size = (width, height);
        self
    }
    
    pub fn with_thumbnail(mut self, thumbnail_path: PathBuf) -> Self {
        self.thumbnail_path = Some(thumbnail_path);
        self
    }
    
    pub fn add_tag(&mut self, tag: String) {
        if !self.tags.contains(&tag) {
            self.tags.push(tag);
        }
    }
    
    pub fn remove_tag(&mut self, tag: &str) {
        self.tags.retain(|t| t != tag);
    }
} 