use bevy::prelude::*;
use a_shader_a_day::shader_utils::common_2d::{Common2dPlugin, ShaderPathProvider};

#[derive(Clone, Default, TypePath)]
struct PolarCoordinateShader;

impl ShaderPathProvider for PolarCoordinateShader {
    const PATH: &'static str = "shaders/polar_coordinate.wgsl";
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins,
            Common2dPlugin::<PolarCoordinateShader>::default(),
        ))
        .run();
}