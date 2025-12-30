use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct PatternShader;

impl ShaderPathProvider for PatternShader {
    const PATH: &'static str = "shaders/pattern.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<PatternShader>::default(),
        ))
        .run();
}