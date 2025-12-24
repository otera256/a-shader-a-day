#import bevy_sprite::mesh2d_view_bindings::globals;
#import bevy_sprite::mesh2d_vertex_output::VertexOutput;
#import bevy_render::view::View;
#import a_shader_a_day::shader_utils::common::{PI, TAU};

@group(0) @binding(0) var<uniform> view: View;

struct WaveParams {
    frequency: f32,
    amplitude: f32,
    speed: f32,
}

fn plot(st: vec2f, pct: f32) -> f32 {
    return smoothstep(pct - 0.02, pct, st.y)
            - smoothstep(pct, pct + 0.02, st.y);
}

@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    var uv = in.uv;
    uv.y = 1.0 - uv.y;
    // uv = (uv * 2.0) - 1.0;
    let t = globals.time;
    let x = uv.x;
    let waves = array<WaveParams, 5>(
        WaveParams(3.0, 0.3, 0.3),
        WaveParams(3.0, 0.15, 0.375),
        WaveParams(3.0, 0.1, 0.5),
        WaveParams(3.0, 0.075, 0.75),
        WaveParams(3.0, 0.06, 1.5),
    );
    var y = 0.5;
    for (var i = 0; i < 5; i++) {
        let wave = waves[i];
        y += sin((x + t * wave.speed) * wave.frequency * TAU) * wave.amplitude;
    }
    var color = vec3(y);
    let pct = plot(uv, y);
    color = (1.0 - pct) * color + pct * vec3f(0.0, 1.0, 0.0);

    return vec4f(vec3(color), 1.0);
}