#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::PI;

@group(0) @binding(0) var<uniform> view: View;

const ColorA = vec3(0.149,0.141,0.912);
const ColorB = vec3(1.000,0.833,0.224);

fn plot(st: vec2f, pct: f32) -> f32 {
    return smoothstep(pct - 0.01, pct, st.y)
            - smoothstep(pct, pct + 0.01, st.y);
}

@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    var uv = in.uv;
    uv.y = 1.0 - uv.y;

    var color = vec3(0.0);
    var pct = vec3(uv.x);

    pct.r = smoothstep(0.0, 1.0, sin(uv.x * PI / 2.0));
    pct.g = sin(uv.x * PI);
    pct.b = pow(uv.x, 0.5);

    color = mix(ColorA, ColorB, pct);

    color = mix(color, vec3(1.0, 0.0, 0.0), plot(uv, pct.r));
    color = mix(color, vec3(0.0, 1.0, 0.0), plot(uv, pct.g));
    color = mix(color, vec3(0.0, 0.0, 1.0), plot(uv, pct.b));

    return vec4(color, 1.0);
}
