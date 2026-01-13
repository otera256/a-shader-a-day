#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::{PI, TAU, E, rotate2D};

@group(0) @binding(0) var<uniform> view: View;

fn hash(p: vec2f) -> f32 {
    var p3 = fract(vec3f(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

fn random(p: vec2f) -> vec2f {
    return vec2f(
        hash(p + vec2f(0.0, 0.0)),
        hash(p + vec2f(5.2, 1.3))
    ) * 2.0 - 1.0;
}

fn noise(p: vec2f) -> f32 {
    let i = floor(p);
    let f = fract(p);
    let u = f * f * (3.0 - 2.0 * f);

    return mix(
        mix(dot(random(i + vec2f(0.0, 0.0)), f - vec2f(0.0, 0.0)),
            dot(random(i + vec2f(1.0, 0.0)), f - vec2f(1.0, 0.0)), u.x),
        mix(dot(random(i + vec2f(0.0, 1.0)), f - vec2f(0.0, 1.0)),
            dot(random(i + vec2f(1.0, 1.0)), f - vec2f(1.0, 1.0)), u.x),
        u.y
    );
}

fn shape(p: vec2f, radius: f32, t: f32, b: f32, c: f32, d: f32) -> f32 {
    let r = length(p);
    var a = atan2(p.y, p.x);
    var m = abs(fract((a + t * PI + d) / TAU) * TAU - PI) / 3.0;
    var f = radius;
    m += noise(p + t * 0.5) * 0.3;
    a += noise(p + t * 0.1) *0.1;
    for (var i = 1; i <= 5; i++) {
        f += (1.0 / f32(i)) * noise(p + t * f32(i) * b) * c * m;
    }
    f += sin(a * 20.0) * 0.1 * pow(m, 2.0);
    return smoothstep(f, f + 0.007, r);
}

fn shapeBorder(p: vec2f, radius: f32, width: f32, t: f32, b: f32, c: f32, d: f32) -> f32 {
    return shape(p, radius - width, t, b, c, d) - shape(p, radius, t, b, c, d);
}

fn aurora(p: vec2f, t: f32, seed: vec2f) -> f32 {
    var r = length(p);
    var a = atan2(p.y, p.x);
    r *= 1.0 + noise(p * 0.5 + seed) * 2.0;
    a += noise(p + t * TAU + seed) * 0.1;
    let q = vec2f(cos(a), sin(a)) * pow(r, -0.5);
    let f = noise(q * sin(t) * 5.0 + t) * 0.1;
    return f;
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

    color += vec3(
        shapeBorder(uv, 0.8, 0.02, t, 1.0, 0.2, 0.0),
        shapeBorder(uv, 0.8, 0.02, t, 0.9, 0.2, sin(t) * 0.5),
        shapeBorder(uv, 0.8, 0.02, t, 1.1, 0.2, cos(t) * 0.5)
    );

    // 放射状のオーロラ
    color += vec3(
        aurora(uv, t, vec2f(12.34, 56.78)),
        aurora(uv, t, vec2f(34.56, 78.90)),
        aurora(uv, t, vec2f(56.78, 90.12))
    );

    return vec4(color, 1.0);
}