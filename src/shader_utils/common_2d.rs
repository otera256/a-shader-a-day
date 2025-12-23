use std::marker::PhantomData;

use bevy::{prelude::*, render::render_resource::AsBindGroup, shader::ShaderRef, sprite_render::{Material2d, Material2dPlugin}, window::WindowResized};

// 共通用の2Dプラグイン
// シェーダのパスを型レベルで指定することで、複数のシェーダを切り替えて使えるようにする
// 仮想的な平面上での座標をシェーダーに渡し、またマウス操作等によるインタラクションも可能にする
pub struct Common2dPlugin<T: ShaderPathProvider>(PhantomData<T>);

impl<T: ShaderPathProvider> Default for Common2dPlugin<T> {
    fn default() -> Self {
        Self(PhantomData)
    }
}

impl<T: ShaderPathProvider> Plugin for Common2dPlugin<T> {
    fn build(&self, app: &mut App) {
        app
            .add_plugins(Material2dPlugin::<MyMaterial2d<T>>::default())
            .insert_resource(MyMaterial2dHandle::<T>::default())
            .add_systems(Startup, setup::<T>)
            .add_systems(Update, (
                resize_quad::<T>.run_if(on_message::<WindowResized>),
                update_mouse_pos::<T>,
            ));
    }
}

pub trait ShaderPathProvider: Send + Sync + TypePath + Clone + Default + 'static {
    const PATH: &'static str;
}
// シェーダにCPU側から値を渡すためのマテリアル定義
#[derive(Asset, TypePath, AsBindGroup, Debug, Clone)]
struct MyMaterial2d<T: ShaderPathProvider> {
    // マウス座標（UV座標系）
    #[uniform(0)]
    mouse: Vec2,

    _marker: PhantomData<T>
}

impl<T: ShaderPathProvider> Default for MyMaterial2d<T> {
    fn default() -> Self {
        Self {
            mouse: Vec2::ZERO,
            _marker: PhantomData,
        }
    }
}

impl<T: ShaderPathProvider> Material2d for MyMaterial2d<T> {
    fn fragment_shader() -> ShaderRef {
        T::PATH.into()
    }
}

#[derive(Resource, Default)]
struct MyMaterial2dHandle<T: ShaderPathProvider>(Handle<MyMaterial2d<T>>);

#[derive(Component)]
struct ScreenQuad;

fn setup<T: ShaderPathProvider>(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<MyMaterial2d<T>>>,
    mut my_material_handle: ResMut<MyMaterial2dHandle<T>>,
){
    commands.spawn(Camera2d);

    let handle = materials.add(MyMaterial2d::<T>::default());
    my_material_handle.0 = handle.clone();

    commands.spawn((
        Mesh2d(meshes.add(Rectangle::default())),
        ScreenQuad,
        MeshMaterial2d(handle),
    ));
}

fn resize_quad<T: ShaderPathProvider>(
    window: Single<&Window>,
    mut quad_transform: Single<&mut Transform, With<ScreenQuad>>,
){
    let width = window.width();
    let height = window.height();

    // もともとのScreenQuadの大きさは1×1なので、ウィンドウサイズに合わせてスケーリングする
    quad_transform.scale = Vec3::new(width, height, 1.0);

    info!("Screen Resized to: {} x {}", width, height);
}

fn update_mouse_pos<T: ShaderPathProvider>(
    window: Single<&Window>,
    my_material_handle: Res<MyMaterial2dHandle<T>>,
    mut materials: ResMut<Assets<MyMaterial2d<T>>>,
){
    if let Some(material) = materials.get_mut(&my_material_handle.0) {
        if let Some(cursor_pos) = window.cursor_position() {
            let uv_x = cursor_pos.x / window.width();
            let uv_y = cursor_pos.y / window.height();
            material.mouse = Vec2::new(uv_x, uv_y);
        } else {
            material.mouse = Vec2::ZERO;
        }
    }
}