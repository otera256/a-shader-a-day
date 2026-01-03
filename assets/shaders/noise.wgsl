#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::{PI, TAU, E, rotate2D};

@group(0) @binding(0) var<uniform> view: View;

fn hash1D(n: f32) -> f32 {
    return fract(sin(n) * 43758.5453123);
}

fn hash2D(p: vec2f) -> f32 {
    var p3 = fract(vec3f(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

fn random2(st: vec2f) -> vec2f {
    return vec2f(
        hash2D(st + vec2f(0.0, 0.0)),
        hash2D(st + vec2f(5.2, 1.3))
    ) * 2.0 - 1.0;
}

// 1次元のノイズ関数
fn valueNoise1D(x: f32) -> f32 {
    let i = floor(x);
    let f = fract(x);
    let u = f * f * (3.0 - 2.0 * f);
    return mix(hash1D(i), hash1D(i + 1.0), u);
}

// 2次元のノイズ関数
fn valueNoise2D(uv: vec2f) -> f32 {
    let i = floor(uv);
    let f = fract(uv);
    let u = f * f * (3.0 - 2.0 * f);

    let a = hash2D(i);
    let b = hash2D(i + vec2f(1.0, 0.0));
    let c = hash2D(i + vec2f(0.0, 1.0));
    let d = hash2D(i + vec2f(1.0, 1.0));

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

fn gradientNoise2D(uv: vec2f) -> f32 {
    let i = floor(uv);
    let f = fract(uv);
    let u = f * f * (3.0 - 2.0 * f);

    return mix(
        mix(dot(random2(i + vec2f(0.0, 0.0)), f - vec2f(0.0, 0.0)),
            dot(random2(i + vec2f(1.0, 0.0)), f - vec2f(1.0, 0.0)), u.x),
        mix(dot(random2(i + vec2f(0.0, 1.0)), f - vec2f(0.0, 1.0)),
            dot(random2(i + vec2f(1.0, 1.0)), f - vec2f(1.0, 1.0)), u.x),
        u.y
    );
}

fn lines(pos: vec2f, b: f32, scale: f32) -> f32 {
    return smoothstep(0.0, 0.5 + b * 0.5, abs(sin(pos.x * PI) + b * 2.0) * 0.5);
}

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

    // オーロラ風ノイズ
    // color = vec3(
    //     valueNoise1D(uv.x * 3.0 + t),
    //     valueNoise1D(uv.x * 5.0 - t * 0.5),
    //     valueNoise1D(uv.x * 7.0 + t * 1.5)
    // );

    // dancing squares
    // for (var i = 0; i < 10; i++) {
    //     let center = vec2(
    //         hash1D(f32(i)) * (valueNoise1D(t * 0.5 + f32(i)) - 0.5) * 2.0,
    //         hash1D(f32(i) + 1.0) * (valueNoise1D(t * 0.3 + f32(i) + 5.0) - 0.5) * 2.0
    //     );
    //     let angle = valueNoise1D(t + f32(i) * 1.3) * TAU;
    //     let size = 0.1 + valueNoise1D(t + f32(i) * 2.0) * 0.2;
    //     color += vec3(1.0) * square_border(
    //         rotate2D(-angle) * (uv - center) + center,
    //         center,
    //         size,
    //         0.02
    //     );
    // }

    // noise 2D
    // color = vec3(
    //     valueNoise2D(uv * 3.0 + vec2f(t * 0.5, t * 0.5)),
    //     valueNoise2D(uv * 5.0 - vec2f(t * 0.3, t * 0.3)),
    //     valueNoise2D(uv * 7.0 + vec2f(t * 1.5, t * 1.5))
    // );

    // gradient noise 2D
    // color = vec3(
    //     gradientNoise2D(uv * 3.0 + vec2f(t * 0.7, t * 0.5)),
    //     gradientNoise2D(uv * 5.0 - vec2f(t * 0.4, t * 0.3)),
    //     gradientNoise2D(uv * 7.0 + vec2f(t * 1.2, t * 1.5))
    // );

    // wood grain
    var pos = rotate2D(gradientNoise2D(uv * t)) * uv * 10.0;
    pos = rotate2D(gradientNoise2D(pos + vec2(t))) * pos;
    let pattern = lines(pos, abs(sin(t)), 10.0);
    color = vec3(pattern);

    return vec4(color, 1.0);
}