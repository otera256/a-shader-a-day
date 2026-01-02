#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View
#import a_shader_a_day::shader_utils::common::{PI, TAU, E, rotate2D};

@group(0) @binding(0) var<uniform> view: View;

fn random(seed: vec2f) -> f32 {
    let a = 12.9898;
    let b = 78.233;
    let c = 43758.5453123;
    let dt = dot(seed, vec2f(a, b));
    let sn = fract(sin(dt) * c);
    return sn;
}

fn trucherPattern(uv: vec2f, index: f32) -> vec2f {
    let i = fract((index - 0.5) * 2.0);
    if i > 0.75 {
        return vec2(1.0) - uv;
    } else if i > 0.5 {
        return vec2(1.0 - uv.x, uv.y);
    } else if i > 0.25 {
        return vec2(uv.x, 1.0 - uv.y);
    } else {
        return uv;
    }
}

@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    var uv = in.uv;
    uv = (2.0 * uv) - 1.0;
    let resolution = view.viewport.zw;
    uv.x *= resolution.x / resolution.y;
    uv.y *= -1.0;
    let t = globals.time;
    var color = 0.0;

    // uv *= 4.0;
    // uv.x += t * 3.0;
    // let ipos = floor(uv);
    // var fpos = fract(uv);

    // let tile = trucherPattern(fpos, random(ipos));

    // Maze
    // color = smoothstep(tile.x - 0.3, tile.x, tile.y)
    //         - smoothstep(tile.x, tile.x + 0.3, tile.y);

    // Circles
    // color = (
    //     step(length(tile), 0.6) -
    //     step(length(tile), 0.4)
    // ) + (
    //     step(length(tile - vec2(1.0)), 0.6) - 
    //     step(length(tile - vec2(1.0)), 0.4)
    // );

    // Truchet (2 triangles)
    // color = step(tile.x, tile.y);

    // Bars
    // let sign_y = sign(uv.y);
    // color = step(random(vec2(floor(uv.x * 100.0 + 100.0 * t * sign_y), sign_y)), 0.7);

    // Many moving bars
    color = 1.0;
    let row = sign(uv.y) * floor(pow(abs(uv.y) + 0.001, -0.3) * 30.0);
    let speed = random(vec2(row, row)) * 300.0 - 150.0;
    let pos = vec2(
        floor(uv.x * 30.0 - t * speed),
        floor(uv.y * 50.0 + sin(t * speed) * 0.5)
    );
    var threshold = 0.5;
    for (var i = 0; i < 10; i++) {
        threshold += (0.5 / f32(i + 1)) * sin(PI * t * random(vec2(f32(i))) + abs(row) * 0.01);
    }
    color = step(random(pos), smoothstep(0.0, 1.0, threshold));

    return vec4(vec3(color), 1.0);
}