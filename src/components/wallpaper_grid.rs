use crate::models::Wallpaper;

/// 壁纸网格组件，处理壁纸的网格布局逻辑
pub struct WallpaperGrid {
    wallpapers: Vec<Wallpaper>,
    columns: usize,
    selected_index: Option<usize>,
}

impl WallpaperGrid {
    pub fn new(columns: usize) -> Self {
        Self {
            wallpapers: Vec::new(),
            columns,
            selected_index: None,
        }
    }
    
    pub fn set_wallpapers(&mut self, wallpapers: Vec<Wallpaper>) {
        self.wallpapers = wallpapers;
        self.selected_index = None;
    }
    
    pub fn get_wallpapers(&self) -> &[Wallpaper] {
        &self.wallpapers
    }
    
    pub fn set_columns(&mut self, columns: usize) {
        self.columns = columns.max(1);
    }
    
    pub fn get_columns(&self) -> usize {
        self.columns
    }
    
    pub fn get_rows(&self) -> usize {
        if self.wallpapers.is_empty() {
            0
        } else {
            (self.wallpapers.len() + self.columns - 1) / self.columns
        }
    }
    
    pub fn select_wallpaper(&mut self, index: usize) -> Option<&Wallpaper> {
        if index < self.wallpapers.len() {
            self.selected_index = Some(index);
            Some(&self.wallpapers[index])
        } else {
            None
        }
    }
    
    pub fn get_selected_wallpaper(&self) -> Option<&Wallpaper> {
        self.selected_index
            .and_then(|index| self.wallpapers.get(index))
    }
    
    pub fn get_selected_index(&self) -> Option<usize> {
        self.selected_index
    }
    
    pub fn clear_selection(&mut self) {
        self.selected_index = None;
    }
    
    pub fn move_selection(&mut self, direction: Direction) -> Option<&Wallpaper> {
        if self.wallpapers.is_empty() {
            return None;
        }
        
        let current_index: usize = self.selected_index.unwrap_or(0);
        let new_index: Option<usize> = match direction {
            Direction::Up => {
                if current_index >= self.columns {
                    Some(current_index - self.columns)
                } else {
                    None
                }
            }
            Direction::Down => {
                let new_idx: usize = current_index + self.columns;
                if new_idx < self.wallpapers.len() {
                    Some(new_idx)
                } else {
                    None
                }
            }
            Direction::Left => {
                if current_index > 0 {
                    Some(current_index - 1)
                } else {
                    None
                }
            }
            Direction::Right => {
                let new_idx: usize = current_index + 1;
                if new_idx < self.wallpapers.len() {
                    Some(new_idx)
                } else {
                    None
                }
            }
        };
        
        if let Some(index) = new_index {
            self.select_wallpaper(index)
        } else {
            self.get_selected_wallpaper()
        }
    }
    
    pub fn filter_by_aspect_ratio(&self, min_ratio: f32, max_ratio: f32) -> Vec<&Wallpaper> {
        self.wallpapers
            .iter()
            .filter(|wallpaper| {
                let ratio: f32 = wallpaper.size.0 as f32 / wallpaper.size.1 as f32;
                ratio >= min_ratio && ratio <= max_ratio
            })
            .collect()
    }
    
    pub fn sort_by_size(&mut self, ascending: bool) {
        self.wallpapers.sort_by(|a, b| {
            let size_a: u64 = a.size.0 as u64 * a.size.1 as u64;
            let size_b: u64 = b.size.0 as u64 * b.size.1 as u64;
            
            if ascending {
                size_a.cmp(&size_b)
            } else {
                size_b.cmp(&size_a)
            }
        });
        
        self.selected_index = None;
    }
    
    pub fn sort_by_name(&mut self, ascending: bool) {
        self.wallpapers.sort_by(|a, b| {
            if ascending {
                a.filename.cmp(&b.filename)
            } else {
                b.filename.cmp(&a.filename)
            }
        });
        
        self.selected_index = None;
    }
}

#[derive(Debug, Clone, Copy)]
pub enum Direction {
    Up,
    Down,
    Left,
    Right,
}

#[cfg(test)]
mod tests {
    use super::*;

    fn create_test_wallpaper(id: &str, filename: &str) -> Wallpaper {
        Wallpaper {
            id: id.to_string(),
            path: std::path::PathBuf::from(filename),
            filename: filename.to_string(),
            size: (1920, 1080),
            file_size: 1024,
            format: "jpg".to_string(),
            thumbnail_path: None,
            created_at: chrono::Utc::now(),
            modified_at: chrono::Utc::now(),
            tags: Vec::new(),
        }
    }

    #[test]
    fn test_wallpaper_grid_basic() {
        let mut grid: WallpaperGrid = WallpaperGrid::new(3);
        assert_eq!(grid.get_columns(), 3);
        assert_eq!(grid.get_rows(), 0);
        
        let wallpapers: Vec<Wallpaper> = vec![
            create_test_wallpaper("1", "test1.jpg"),
            create_test_wallpaper("2", "test2.jpg"),
            create_test_wallpaper("3", "test3.jpg"),
            create_test_wallpaper("4", "test4.jpg"),
        ];
        
        grid.set_wallpapers(wallpapers);
        assert_eq!(grid.get_wallpapers().len(), 4);
        assert_eq!(grid.get_rows(), 2);
    }

    #[test]
    fn test_selection() {
        let mut grid: WallpaperGrid = WallpaperGrid::new(2);
        let wallpapers: Vec<Wallpaper> = vec![
            create_test_wallpaper("1", "test1.jpg"),
            create_test_wallpaper("2", "test2.jpg"),
        ];
        
        grid.set_wallpapers(wallpapers);
        
        assert!(grid.select_wallpaper(0).is_some());
        assert_eq!(grid.get_selected_index(), Some(0));
        
        assert!(grid.select_wallpaper(5).is_none());
        assert_eq!(grid.get_selected_index(), Some(0));
    }
} 