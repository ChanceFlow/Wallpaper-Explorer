use crate::Result;
use crate::config::Config;
use crate::services::WallpaperService;
use crate::ui::MainWindow;

pub struct App {
    #[allow(dead_code)]
    config: Config,
    #[allow(dead_code)]
    wallpaper_service: WallpaperService,
    main_window: MainWindow,
}

impl App {
    pub fn new() -> Result<Self> {
        let config: Config = Config::load()?;
        let wallpaper_service: WallpaperService = WallpaperService::new(&config)?;
        let main_window: MainWindow = MainWindow::new()?;
        
        Ok(Self {
            config,
            wallpaper_service,
            main_window,
        })
    }
    
    pub fn run(self) -> Result<()> {
        // 设置事件处理器
        self.setup_event_handlers()?;
        
        // 运行主循环
        self.main_window.run()?;
        
        Ok(())
    }
    
    fn setup_event_handlers(&self) -> Result<()> {
        // TODO: 实现事件处理器绑定
        Ok(())
    }
} 