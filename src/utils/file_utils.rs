use std::path::Path;
use crate::Result;

/// 格式化文件大小为人类可读的字符串
pub fn format_file_size(bytes: u64) -> String {
    const UNITS: &[&str] = &["B", "KB", "MB", "GB", "TB"];
    
    if bytes == 0 {
        return "0 B".to_string();
    }
    
    let mut size: f64 = bytes as f64;
    let mut unit_index: usize = 0;
    
    while size >= 1024.0 && unit_index < UNITS.len() - 1 {
        size /= 1024.0;
        unit_index += 1;
    }
    
    if unit_index == 0 {
        format!("{} {}", bytes, UNITS[unit_index])
    } else {
        format!("{:.1} {}", size, UNITS[unit_index])
    }
}

/// 确保目录存在，如果不存在则创建
pub fn ensure_directory_exists(path: &Path) -> Result<()> {
    if !path.exists() {
        std::fs::create_dir_all(path)?;
    }
    Ok(())
}

/// 获取文件的相对路径显示
pub fn get_relative_path_display(path: &Path, base: &Path) -> String {
    if let Ok(relative) = path.strip_prefix(base) {
        relative.to_string_lossy().to_string()
    } else {
        path.to_string_lossy().to_string()
    }
}

/// 安全地删除文件
pub fn safe_remove_file(path: &Path) -> Result<()> {
    if path.exists() && path.is_file() {
        std::fs::remove_file(path)?;
    }
    Ok(())
}

/// 计算目录大小
pub fn calculate_directory_size(path: &Path) -> Result<u64> {
    let mut total_size: u64 = 0;
    
    if path.is_dir() {
        for entry in walkdir::WalkDir::new(path) {
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_format_file_size() {
        assert_eq!(format_file_size(0), "0 B");
        assert_eq!(format_file_size(512), "512 B");
        assert_eq!(format_file_size(1024), "1.0 KB");
        assert_eq!(format_file_size(1536), "1.5 KB");
        assert_eq!(format_file_size(1048576), "1.0 MB");
    }
} 