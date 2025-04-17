// UI module for Vaelix

extern crate glutin;
extern crate gl;

use glutin::config::{Config, ConfigTemplateBuilder};
use glutin::context::{ContextApi, ContextAttributesBuilder, PossiblyCurrentContext, Version};
use glutin::display::{Display, DisplayApiPreference};
use glutin::prelude::*;
use glutin::surface::{Surface, SurfaceAttributesBuilder, WindowSurface};
use raw_window_handle::HasRawWindowHandle;
use std::ffi::CString;
use std::num::NonZeroU32;
use winit::dpi::PhysicalSize;
use winit::event::{Event, WindowEvent};
use winit::event_loop::{ControlFlow, EventLoop};
use winit::window::WindowBuilder;

pub fn initialize_ui() {
    println!("Initializing UI...");

    // Create an event loop
    let event_loop = EventLoop::new();

    // Create a window
    let window_builder = WindowBuilder::new()
        .with_title("Vaelix Browser")
        .with_inner_size(PhysicalSize::new(800, 600));

    let window = window_builder.build(&event_loop).unwrap();
    let raw_window_handle = window.raw_window_handle();

    // Create a display
    let display = unsafe {
        Display::new(raw_window_handle, DisplayApiPreference::Default).unwrap()
    };

    // Create a configuration
    let config_template = ConfigTemplateBuilder::new().build();
    let config = unsafe { display.find_configs(config_template).unwrap().next().unwrap() };

    // Create a context
    let context_attributes = ContextAttributesBuilder::new()
        .with_context_api(ContextApi::OpenGl(Some(Version::new(2, 1))))
        .build(Some(raw_window_handle));
    let context = unsafe { display.create_context(&config, &context_attributes).unwrap() };

    // Create a surface
    let surface_attributes = SurfaceAttributesBuilder::<WindowSurface>::new().build(
        raw_window_handle,
        NonZeroU32::new(1).unwrap(),
        NonZeroU32::new(1).unwrap(), // Add the third argument
    );
    let surface = unsafe {
        display.create_window_surface(&config, &surface_attributes).unwrap()
    };

    let context = unsafe { context.make_current(&surface).unwrap() };

    // Load OpenGL functions
    gl::load_with(|symbol| {
        let c_str = CString::new(symbol).unwrap();
        display.get_proc_address(&c_str)
    });

    // Set up OpenGL viewport
    unsafe {
        gl::Viewport(0, 0, 800, 600);
        gl::ClearColor(0.07, 0.07, 0.07, 1.0); // Dark background (#111)
    }

    // Main event loop
    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent { event, .. } => match event {
                WindowEvent::CloseRequested => *control_flow = ControlFlow::Exit,
                _ => (),
            },
            Event::RedrawRequested(_) => {
                unsafe {
                    gl::Clear(gl::COLOR_BUFFER_BIT);
                }
                surface.swap_buffers(&context).unwrap();
            }
            _ => (),
        }
    });
}
