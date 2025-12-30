#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::{PI, TAU, rotate2D};

@group(0) @binding(0) var<uniform> view: View;

fn rotateTilePattern(uv: vec2f) -> vec2f {
    var index = 0.0;
    index += step(1.0, fract(uv.x) * 2.0);
    index += step(1.0, fract(uv.y) * 2.0) * 2.0;

    var st = fract(uv * 2.0) - vec2(0.5);

    if index == 1.0 {
        st *= rotate2D(-PI / 2.0);
    } else if index == 2.0 {
        st *= rotate2D(PI / 2.0);
    } else if index == 3.0 {
        st *= rotate2D(PI);
    }

    return st + vec2(0.5);
}

fn hexagon_pattern(uv: vec2f, size: f32) -> vec2f {
    var st = uv / size;
    st.y = (sqrt(3.0) / 2.0) * st.y - (1.0 / 2.0) * st.x;
    let a = step(1.0, fract(st.x + st.y) * 2.0);
    return st;
}

@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    var uv = in.uv;
    uv = (2.0 * uv) - 1.0;
    let resolution = view.viewport.zw;
    uv.x *= resolution.x / resolution.y;
    uv.y *= -1.0;
    let t = globals.time;
    uv = hexagon_pattern(uv, 0.3);
    return vec4(vec3(fract(uv.x + cos(t)), fract(uv.y + sin(t)), fract(uv.x + uv.y + t)), 1.0);
}