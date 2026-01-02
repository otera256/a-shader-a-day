use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct RandomShader;

impl ShaderPathProvider for RandomShader {
    const PATH: &'static str = "shaders/random.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<RandomShader>::default(),
        ))
        .run();
}