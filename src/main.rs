slint::include_modules!();

fn main() -> Result<(), slint::PlatformError> {
    // 创建主窗口实例
    let main_window: MainWindow = MainWindow::new()?;
    
    // 设置窗口属性
    main_window.set_title("壁纸浏览器 - Wallpaper Explorer Alpha v0.1.0".into());
    
    // 运行应用程序主循环
    main_window.run()
}
