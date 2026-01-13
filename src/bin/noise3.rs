use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct Noise3Shader;

impl ShaderPathProvider for Noise3Shader {
    const PATH: &'static str = "shaders/noise3.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<Noise3Shader>::default(),
        ))
        .run();
}