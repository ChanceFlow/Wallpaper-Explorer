use Wallpaper_Explorer::App;

fn main() -> Wallpaper_Explorer::Result<()> {
    // 初始化日志记录
    env_logger::init();
    
    // 创建并运行应用程序
    let app: App = App::new()?;
    app.run()?;
    
    Ok(())
}
