#import bevy_sprite::mesh2d_view_bindings::globals 
#import bevy_sprite::mesh2d_vertex_output::VertexOutput
#import bevy_render::view::View

@group(0) @binding(0) var<uniform> view: View;

struct SolutionOrbit {
    root: vec2f,
    phase_speed: vec2f,
    amplitude: vec2f,
    color: vec3f,
};

const NUM_SOLUTIONS: u32 = 3;

const SOLUTIONS: array<SolutionOrbit, 3> = array<SolutionOrbit, 3>(
    SolutionOrbit(
        vec2f(1.0, 0.0),
        vec2f(0.5, 0.3),
        vec2f(0.5, 0.4),
        vec3f(0.6, 0.1, 0.2)
    ),
    SolutionOrbit(
        vec2f(-0.5, 0.866),
        vec2f(0.4, 0.6),
        vec2f(0.7, 0.2),
        vec3f(0.1, 0.6, 0.3)
    ),
    SolutionOrbit(
        vec2f(-0.5, -0.866),
        vec2f(0.6, 0.4),
        vec2f(0.2, 0.6),
        vec3f(0.2, 0.3, 0.7)
    )
);

fn position_of_solution(orbit: SolutionOrbit, time: f32) -> vec2f {
    return orbit.root + vec2f(
        orbit.amplitude.x * cos(time * orbit.phase_speed.x),
        orbit.amplitude.y * sin(time * orbit.phase_speed.y)
    );
}

fn get_colosest_solution(z: vec2f) -> vec3f {
    var closest_color = vec3f(0.0);
    var min_distance = 1e10;
    for (var i = 0; i < 3; i++) {
        let root = position_of_solution(SOLUTIONS[i], globals.time);
        let distance = length(z - root);
        if (distance < min_distance) {
            min_distance = distance;
            closest_color = SOLUTIONS[i].color;
        }
    }
    return closest_color;
}

fn complex_mul(a: vec2f, b: vec2f) -> vec2f {
    return vec2f(
        a.x * b.x - a.y * b.y,
        a.x * b.y + a.y * b.x
    );
}

fn complex_div(a: vec2f, b: vec2f) -> vec2f {
    let denom = dot(b, b);
    return vec2f(
        (a.x * b.x + a.y * b.y) / denom,
        (a.y * b.x - a.x * b.y) / denom
    );
}

fn f(z: vec2f) -> vec2f {
    // f(z) = (z - r1)(z - r2)(z - r3)
    var result = vec2f(1.0, 0.0); // 1 + 0i
    for (var i = 0; i < 3; i++) {
        let root = position_of_solution(SOLUTIONS[i], globals.time);
        let diff = vec2f(z.x - root.x, z.y - root.y);
        result = complex_mul(result, diff);
    }
    return result;
}

fn df(z: vec2f) -> vec2f {
    // f'(z) = f(z) * Σ(1 / (z - ri))
    var sum = vec2f(0.0, 0.0);
    let fz = f(z);
    for (var i = 0; i < 3; i++) {
        let root = position_of_solution(SOLUTIONS[i], globals.time);
        let diff = vec2f(z.x - root.x, z.y - root.y);
        sum = sum + complex_div(vec2f(1.0, 0.0), diff);
    }
    let derivative = complex_mul(fz, sum);
    return derivative;
}

fn newton_step(z: vec2f) -> vec2f {
    let fz = f(z);
    let dfz = df(z);
    return z - complex_div(fz, dfz);
}

@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    var uv = in.uv;
    uv = (2.0 * uv) - 1.0;
    let resolution = view.viewport.zw;
    uv.x *= resolution.x / resolution.y;
    uv.y *= -1.0;
    let t = globals.time;

    let max_iterations = 32;
    var z = uv;
    var color = vec3f(0.0);
    for (var i = 0; i < max_iterations; i++) {
        let prev_z = z;
        z = newton_step(z);
        let diff = length(z - prev_z);
        if (diff < 0.0001) {
            color = get_colosest_solution(z);
            break;
        }
    }
    return vec4<f32>(color, 1.0);
}
