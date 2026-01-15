#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::{PI, TAU, rotate2D};

@group(0) @binding(0) var<uniform> view: View;

// 重六角推フラクタルのSDF
fn sdH6fractal(pos: vec3f, iterations: u32) -> f32 {
    var p = pos;
    var scale = 1.0;

    let d_pole = vec3(1.0, 1.0, 1.0);
    let d_eq   = vec3(1.0, 0.0, -1.0);
    let d_zero = vec3(0.0, 0.0, 0.0);
    // 重六角推の頂点は(1,1,1),(-1,-1,-1),(-1,0,1),(-1,1,0),(0,-1,1),(0,1,-1),(1,-1,0),(1,0,-1)
    for (var i = 0u; i < iterations; i++) {
        if (p.x + p.y + p.z < 0.0) {
            p = -p;
        }
        if (p.x < p.y) {
            let t = p.xy;
            p.x = t.y;
            p.y = t.x;
        }
        if (p.x < p.z) {
            let t = p.xz;
            p.x = t.y;
            p.z = t.x;
        }
        if (p.y < p.z) {
            let t = p.yz;
            p.y = t.y;
            p.z = t.x;
        }
        let dist_pole = dot(p - d_pole, p - d_pole);
        let dist_eq   = dot(p - d_eq,   p - d_eq);
        let dist_zero = dot(p - d_zero, p - d_zero);
        if (dist_pole < dist_zero && dist_pole < dist_eq) {
            p -= d_pole;
        } else if (dist_eq < dist_zero) {
            p -= d_eq;
        } else {
            p -= d_zero;
        }
        p *= 3.0;
        scale *= 3.0;
    }
    return (length(p) - 3.0) / scale;
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

    // カメラ位置とレイ方向の設定
    let omega = PI * 0.2;
    let cam_pos = vec3(rotate2D(t * omega) * vec2(12.0, 0.0), 0.0);
    let display_pos = vec3(rotate2D(t * omega) * vec2(4.0 , uv.x), uv.y);
    let ray_dir = normalize(display_pos - cam_pos);
    // レイマーチング
    var total_dist = 0.0;
    for (var step = 0; step < 200; step++) {
        let current_pos = cam_pos + ray_dir * total_dist;
        let dist = sdH6fractal(current_pos, 10u);
        if (dist < 0.001) {
            color = vec3(1.0 - pow(f32(step) / 100.0, 0.4)) * vec3(0.6, 0.8, 1.0);
            break;
        }
        if (total_dist > 15.0) {
            break;
        }
        total_dist += dist;
    }
    return vec4(color, 1.0);
}