use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct NoiseShader;

impl ShaderPathProvider for NoiseShader {
    const PATH: &'static str = "shaders/noise.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<NoiseShader>::default(),
        ))
        .run();
}