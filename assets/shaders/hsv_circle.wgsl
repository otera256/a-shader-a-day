#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::{hsv2rgb, PI, TAU};

@group(0) @binding(0) var<uniform> view: View;

@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    var uv = in.uv;
    uv = (2.0 * uv) - 1.0;
    let resolution = view.viewport.zw;
    uv.x *= resolution.x / resolution.y;

    let t = globals.time;

    var color = vec3(0.0);

    let angle = atan2(uv.y, uv.x);
    let radius = length(uv);

    color = hsv2rgb(vec3(
        fract(angle / TAU + t * 0.1),
        radius,
        1.0
    ));

    return vec4(color, 1.0);
}
