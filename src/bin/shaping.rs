use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct ShapingShader;

impl ShaderPathProvider for ShapingShader {
    const PATH: &'static str = "shaders/shaping.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<ShapingShader>::default(),
        ))
        .run();
}