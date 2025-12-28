#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::{PI, TAU, E, rotate2D, hsv2rgb};

@group(0) @binding(0) var<uniform> view: View;

@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    var uv = in.uv;
    uv = (2.0 * uv) - 1.0;
    let resolution = view.viewport.zw;
    uv.x *= resolution.x / resolution.y;
    uv.y *= -1.0;
    let t = globals.time;
    var color = vec3(0.0);

    // 波紋が干渉するアニメーション
    // 波源の速度 (source_radius * angular_speed) よりも速い波の速度を設定
    let speed = 1.0;
    let source_radius = 0.6;
    let angular_speed = 1.0;

    for (var i = 0; i < 6; i++) {
        let phase_offset = f32(i) * (TAU / 6.0);
        
        // 不動点反復法で発射時刻 t_emit を求める
        // 方程式: |uv - center(t_emit)| = speed * (t - t_emit)
        // 変形: t_emit = t - |uv - center(t_emit)| / speed
        var t_emit = t;
        for (var j = 0; j < 10; j++) {
            let angle = t_emit * angular_speed + phase_offset;
            let center = vec2(cos(angle), sin(angle)) * source_radius;
            let dist = length(uv - center);
            t_emit = t - dist / speed;
        }

        // 収束した t_emit を使って波の状態を決定
        let wave = 0.2 * sin(t_emit * 10.0) + 0.1;

        // 色も発射時刻に基づいて変化
        color += hsv2rgb(vec3(f32(i) / 6.0, 1.0, wave));
    }

    return vec4(color, 1.0);
}