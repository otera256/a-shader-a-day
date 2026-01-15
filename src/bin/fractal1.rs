use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct Fractal1Shader;

impl ShaderPathProvider for Fractal1Shader {
    const PATH: &'static str = "shaders/fractal1.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<Fractal1Shader>::default(),
        ))
        .run();
}