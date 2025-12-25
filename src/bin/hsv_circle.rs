use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct HsvShader;

impl ShaderPathProvider for HsvShader {
    const PATH: &'static str = "shaders/hsv_circle.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<HsvShader>::default(),
        ))
        .run();
}