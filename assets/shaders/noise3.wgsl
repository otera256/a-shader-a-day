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
    );
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


@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    var uv = in.uv;
    uv = (2.0 * uv) - 1.0;
    let resolution = view.viewport.zw;
    uv.x *= resolution.x / resolution.y;
    uv.y *= -1.0;
    let t = globals.time;
    var color = vec3(0.0);

    var pos = uv * 2.0;
    var strength = 3.0;
    for (var i = 0; i < 6; i++) {
        let theta = t * 0.3 + f32(i) * TAU / 3.0;
        pos += strength * (-1.0 * 2.0 * vec2(noise(pos + 0.3 * cos(theta)), noise(pos + vec2(5.2, 1.3) + 0.3 * sin(theta))));
        strength *= 0.8;
    }

    let i_pos = floor(pos);
    let f_pos = fract(pos);

    var m_dist = 1000.0;

    for (var dy = -1; dy <= 1; dy++) {
        for (var dx = -1; dx <= 1; dx++) {
            let neighbor = vec2f(f32(dx), f32(dy));
            var point = random(i_pos + neighbor);
            point = 0.5 + 0.5 * sin(t + TAU * point * 10.0);
            let diff = f_pos - neighbor - point;
            // let dist = length(diff);
            var dist = abs(diff.x) + abs(diff.y);
            dist *= noise(i_pos + neighbor + vec2(t * 0.5)) + 0.5;
            m_dist = min(m_dist, dist);
        }
    }

    color = vec3(m_dist);

    return vec4(color, 1.0);
}