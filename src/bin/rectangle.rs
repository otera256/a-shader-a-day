use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct RectangleShader;

impl ShaderPathProvider for RectangleShader {
    const PATH: &'static str = "shaders/rectangle.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<RectangleShader>::default(),
        ))
        .run();
}