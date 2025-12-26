#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::{PI, TAU, E, rotate2D};

@group(0) @binding(0) var<uniform> view: View;

fn rectangle(uv: vec2f, start: vec2f, end: vec2f) -> f32 {
    let lower = step(start, uv);
    let upper = step(uv, end);
    return lower.x * lower.y * upper.x * upper.y;
}

fn smooth_rectangle(uv: vec2f, start: vec2f, end: vec2f, smoothness: f32) -> f32 {
    let lower_x = smoothstep(start.x - smoothness / 2.0, start.x + smoothness / 2.0, uv.x);
    let lower_y = smoothstep(start.y - smoothness / 2.0, start.y + smoothness / 2.0, uv.y);
    let upper_x = smoothstep(end.x + smoothness / 2.0, end.x - smoothness / 2.0, uv.x);
    let upper_y = smoothstep(end.y + smoothness / 2.0, end.y - smoothness / 2.0, uv.y);
    return lower_x * lower_y * upper_x * upper_y;
}

fn rectangle_border(uv: vec2f, start: vec2f, end: vec2f, border_thickness: f32) -> f32 {
    let inner_start = start + vec2f(border_thickness / 2.0);
    let inner_end = end - vec2f(border_thickness / 2.0);
    let outer_start = start - vec2f(border_thickness / 2.0);
    let outer_end = end + vec2f(border_thickness / 2.0);
    let outer = smooth_rectangle(uv, outer_start, outer_end, 0.005);
    let inner = smooth_rectangle(uv, inner_start, inner_end, 0.005);
    return outer - inner;
}

fn square_border(uv: vec2f, center: vec2f, size: f32, border_thickness: f32) -> f32 {
    let half_size = size / 2.0;
    let start = center - vec2f(half_size);
    let end = center + vec2f(half_size);
    return rectangle_border(uv, start, end, border_thickness);
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

    for (var i = 0; i < 64; i++) {
        // 各パラメータを時間、UV座標、インデックスから決定
        // 特にインデックス座標は乱数的に絡ませる
        let center = vec2(
            cos(t * 0.5 + f32(i) * 1.3) * 1.6,
            sin(t * 0.5 + f32(i) * 1.1) * 0.9
        );
        let rot_speed = 0.1 + fract(f32(i) * PI) * 2.0;
        let tt = t + sin(t);
        let rotation = tt * rot_speed + f32(i) * PI / 4.0;
        let rot_uv = rotate2D(rotation) * (uv - center) + center;
        let size_factor = 0.1 + 0.9 * fract(f32(i) * 0.7);
        let size = (0.1 + 0.7 * fract(f32(i) * E)) * (0.25 + 0.75 * abs(cos(tt * size_factor)));
        let thickness_factor = 0.1 + 0.9 * fract(f32(i) * 1.9);
        let thickness = (0.01 + 0.04 * fract(f32(i) * PI)) * (0.05 + 0.95 * abs(sin(tt * thickness_factor)));
        let opacity = smoothstep(0.0, 0.1, 1.0 - length(uv - center));
        let border = square_border(rot_uv, center, size, thickness);
        color = mix(color, vec3(1.0), border * opacity);
    }

    return vec4(color, 1.0);
}
