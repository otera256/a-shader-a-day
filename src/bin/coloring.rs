use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct ColoringShader;

impl ShaderPathProvider for ColoringShader {
    const PATH: &'static str = "shaders/coloring.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<ColoringShader>::default(),
        ))
        .run();
}