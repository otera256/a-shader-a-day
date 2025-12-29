#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::{PI, TAU, hsv2rgb};

@group(0) @binding(0) var<uniform> view: View;

fn polygon_distance(uv: vec2f, center: vec2f, n: u32, rotation: f32) -> f32 {
    let r = TAU / f32(n);
    let a = atan2(uv.x - center.x, uv.y - center.y) + PI + rotation;
    let d = cos(floor(0.5 + a / r) * r - a) * length(uv - center);
    return d;
}

fn polygon_border(uv: vec2f, center: vec2f, n: u32, size: f32, border_thickness: f32, rotation: f32) -> f32 {
    let d = polygon_distance(uv, center, n, rotation);
    let outer = smoothstep(size + border_thickness / 2.0, size + border_thickness / 2.0 - 0.005, d);
    let inner = smoothstep(size - border_thickness / 2.0, size - border_thickness / 2.0 - 0.005, d);
    return outer - inner;
}

fn hexagram_border(uv: vec2f, center: vec2f, size: f32, border_thickness: f32, rotation: f32) -> f32 {
    let d = min(
        polygon_distance(uv, center, 3u, rotation),
        polygon_distance(uv, center, 3u, rotation + PI / 3.0)
    );
    let outer = smoothstep(size + border_thickness / 2.0, size + border_thickness / 2.0 - 0.005, d);
    let inner = smoothstep(size - border_thickness / 2.0, size - border_thickness / 2.0 - 0.005, d);
    return outer - inner;
}

@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    var uv = in.uv;
    uv = (2.0 * uv) - 1.0;
    let resolution = view.viewport.zw;
    uv.x *= resolution.x / resolution.y;
    uv.y *= -1.0;
    let t = globals.time;
    var color = vec3(0.0);
    let n = 60;

    for (var i = 0; i < n; i++) {
        let angle = t * 0.5 + f32(i) * (TAU / f32(n));
        let center = vec2(cos(angle), sin(angle)) * 0.7;
        let rotation = -angle + PI / 2.0;
        let size = 0.7;
        let border_thickness = 0.02;
        let f = hexagram_border(uv, center, size, border_thickness, rotation);
        let hue = f32(i) / f32(n);
        let value = 0.7 + 0.3 * sin(t + f32(i) / f32(n) * PI);
        color += f * hsv2rgb(vec3(hue, 0.6, value)) * 0.5;
    }

    return vec4(color, 1.0);
}