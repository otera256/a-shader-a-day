#define_import_path a_shader_a_day::shader_utils::common

const PI: f32 = 3.141592653589793;
const TAU: f32 = 6.283185307179586;

const E: f32 = 2.718281828459045;

// RGBカラーをHSVカラーに変換する関数
// 入力: c - RGBカラー (各成分は0.0から1.0の範囲)
// 出力: vec3f(hue, saturation, value)
// 色相(hue): 0.0から1.0の範囲 (0.0が赤、1.0が赤に戻る)]
// 彩度(saturation): 0.0から1.0の範囲
// 明度(value): 0.0から1.0の範囲
// 参考: https://thebookofshaders.com/06/
fn rgb2hsv(c: vec3f) -> vec3f {
    // 色相の計算に用いるオフセット
    let K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    // p.x = max(b, g)
    // p.y = min(b, g)
    // p.zw: rが最大値のときに使用されるオフセット
    let p = select(
        vec4(c.bg, K.wz),
        vec4(c.gb, K.xy),
        c.b <= c.g
    );
    // q.x = max(r, g, b) -> value
    // q.y = p.y = min(g, b)
    // q.w = min(r, max(g, b))
    let q = select(
        vec4(p.xyw, c.r),
        vec4(c.r, p.yzx),
        p.x <= c.r
    );
    // min(q.w, q.y) = min(r, g, b)
    // d: 色の差(chroma)
    let d = q.x - min(q.w, q.y);
    // ゼロ除算防止のための微小値
    let e = 1.0e-10;
    return vec3(
        abs(q.z + (q.w - q.y) / (6.0 * d + e)),// hue
        d / (q.x + e),                         // saturation
        q.x                                    // value
    );
}

// HSVカラーをRGBカラーに変換する関数
// 入力: c - HSVカラー (hue: 0.0から1.0、saturation: 0.0から1.0、value: 0.0から1.0)
// 出力: vec3f(r, g, b) (各成分は0.0から1.0の範囲)
// 参考: Iñigo Quiles
// https://www.shadertoy.com/view/MsS3Wc
fn hsv2rgb(c: vec3f) -> vec3f {
    var rgb = clamp(
        abs(6.0 * fract(c.x + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) - 3.0) - 1.0,
        vec3(0.0), vec3(1.0)
    );
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    // 明度 * mix(白, rgb, 彩度)
    return c.z * mix(vec3(1.0), rgb, c.y);
}

fn rotate2D(angle: f32) -> mat2x2<f32> {
    let c = cos(angle);
    let s = sin(angle);
    return mat2x2<f32>(
        c, -s,
        s,  c
    );
}