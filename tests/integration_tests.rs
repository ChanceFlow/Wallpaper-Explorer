use Wallpaper_Explorer::Result;

#[test]
fn test_app_creation() -> Result<()> {
    // 这里可以添加集成测试
    // 注意：由于GUI应用的特殊性，实际的UI测试可能需要特殊的测试框架
    Ok(())
}

#[test]
fn test_config_loading() -> Result<()> {
    use Wallpaper_Explorer::config::Config;
    
    let config: Config = Config::default();
    assert!(!config.supported_formats.is_empty());
    assert!(config.thumbnail_size.0 > 0);
    assert!(config.thumbnail_size.1 > 0);
    
    Ok(())
} 