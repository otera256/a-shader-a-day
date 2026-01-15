#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::{PI, TAU, rotate2D};

@group(0) @binding(0) var<uniform> view: View;

// シェルピンスキー四面体のSDF
fn sdSierpinski(pos: vec3<f32>, iterations: u32) -> f32 {
    var p = pos;
    var scale = 1.0;
    // 四面体全体の頂点の位置は(1,1,1),(1,-1,-1),(-1,1,-1),(-1,-1,1)
    let offset = vec3(1.0, 1.0, 1.0);

    for (var i = 0u; i < iterations; i++) {
        // 折り返しの結果 x,y,z >= 0 となるようにする
        // 平面 x+y=0 での折り返し
        if (p.x + p.y < 0.0) { 
            let t = p.xy; 
            p.x = -t.y; 
            p.y = -t.x; 
        }
        // 平面 x+z=0 での折り返し
        if (p.x + p.z < 0.0) { 
            let t = p.xz; 
            p.x = -t.y; 
            p.z = -t.x; 
        }
        // 平面 y+z=0 での折り返し
        if (p.y + p.z < 0.0) { 
            let t = p.yz; 
            p.y = -t.y; 
            p.z = -t.x; 
        }

        // 2倍に拡大し、頂点方向 (1,1,1) へ引き戻す
        p = p * 2.0 - offset;
        scale = scale * 2.0;
    }
    // ざっくりとした球での距離を返す
    return (length(p) - 1.5) / scale;
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
    let cam_pos = vec3(rotate2D(t * omega) * vec2(3.0, 0.0), 0.0);
    let display_pos = vec3(rotate2D(t * omega) * vec2(1.2 , uv.x), uv.y);
    let ray_dir = normalize(display_pos - cam_pos);
    // レイマーチング
    var total_dist = 0.0;
    for (var step = 0; step < 100; step++) {
        let current_pos = cam_pos + ray_dir * total_dist;
        let dist = sdSierpinski(current_pos, 10u);
        if (dist < 0.001) {
            color = vec3(1.0 - pow(f32(step) / 100.0, 0.4));
            break;
        }
        if (total_dist > 10.0) {
            break;
        }
        total_dist += dist;
    }
    return vec4(color, 1.0);
}