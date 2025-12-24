#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View

@group(0) @binding(0) var<uniform> view: View;

@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    let uv = in.uv;
    let color = vec3f(
        0.5 + 0.5 * sin(uv.x * 3.0 + globals.time * 1.7),
        0.5 + 0.5 * sin(uv.y * 3.0 + globals.time * 1.9),
        0.5 + 0.5 * sin((uv.x + uv.y) * 3.0 + globals.time * 2.1)
    );
    return vec4<f32>(color, 1.0);
}