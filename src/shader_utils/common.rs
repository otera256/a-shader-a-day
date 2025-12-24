use bevy::{
    asset::{load_internal_asset, uuid_handle},
    prelude::{App, Handle, Plugin, Shader},
};

pub struct MyShaderLibraryPlugin;

pub const MY_SHADER_LIBRARY_HANDLE: Handle<Shader> =
    uuid_handle!("5c5de05f-3058-4dc7-8f4d-1d66d9298b9f");

impl Plugin for MyShaderLibraryPlugin {
    fn build(&self, app: &mut App) {
        load_internal_asset!(
            app,
            MY_SHADER_LIBRARY_HANDLE,
            "common.wgsl",
            Shader::from_wgsl
        );
    }
}