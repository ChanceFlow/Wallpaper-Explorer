use crate::Result;

slint::include_modules!();

pub struct MainWindowWrapper {
    window: MainWindow,
}

impl MainWindowWrapper {
    pub fn new() -> Result<Self> {
        let window: MainWindow = MainWindow::new()?;
        
        Ok(Self { window })
    }
    
    pub fn run(self) -> Result<()> {
        self.window.run()?;
        Ok(())
    }
    
    pub fn show(&self) -> Result<()> {
        self.window.show()?;
        Ok(())
    }
    
    pub fn hide(&self) {
        let _ = self.window.hide();
    }
    
    // 获取内部Slint窗口的引用，用于事件绑定
    pub fn inner(&self) -> &MainWindow {
        &self.window
    }
} 