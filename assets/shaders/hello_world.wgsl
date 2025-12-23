#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View

@group(0) @binding(0) var<uniform> view: View;

@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    let uv = in.uv;
    let color = vec3<f32>(uv, 0.5 + 0.5 * sin(globals.time));
    return vec4<f32>(color, 1.0);
}