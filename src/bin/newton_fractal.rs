use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct NewtonFractalShader;

impl ShaderPathProvider for NewtonFractalShader {
    const PATH: &'static str = "shaders/newton_fractal.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<NewtonFractalShader>::default(),
        ))
        .run();
}