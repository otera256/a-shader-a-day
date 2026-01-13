use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct Noise2Shader;

impl ShaderPathProvider for Noise2Shader {
    const PATH: &'static str = "shaders/noise2.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<Noise2Shader>::default(),
        ))
        .run();
}