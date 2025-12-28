use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct CircleShader;

impl ShaderPathProvider for CircleShader {
    const PATH: &'static str = "shaders/circle.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<CircleShader>::default(),
        ))
        .run();
}