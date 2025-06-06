#![allow(non_snake_case)]

pub mod app;
pub mod components;
pub mod config;
pub mod error;
pub mod models;
pub mod services;
pub mod ui;
pub mod utils;

pub use app::App;
pub use error::{Result, WallpaperError}; 