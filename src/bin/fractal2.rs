use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct Fractal2Shader;

impl ShaderPathProvider for Fractal2Shader {
    const PATH: &'static str = "shaders/fractal2.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<Fractal2Shader>::default(),
        ))
        .run();
}