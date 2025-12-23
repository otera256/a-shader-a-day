use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct HelloWorldShader;

impl ShaderPathProvider for HelloWorldShader {
    const PATH: &'static str = "shaders/hello_world.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<HelloWorldShader>::default(),
        ))
        .run();
}