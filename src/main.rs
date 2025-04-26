mod core;
mod ui;
mod ai;
mod plugins;
mod devtools;
mod extensions;
mod network;
mod security;
mod utils;

use ui::command_palette::command_palette;
use ui::tab_memory::TabMemory;
use security::firewall::Firewall;
use core::protocols::protocols::ProtocolHandler;
use plugins::sandbox::PluginSandbox;
use ui::tab_snapshot::TabSnapshot;
use web_view::Content;

fn main() {
    let mut webview = web_view::builder()
        .title("Vaelix Browser")
        .content(Content::Html("Hello, Vaelix!"))
        .size(800, 600)
        .resizable(true)
        .debug(true)
        .user_data(()) // Pass user data to the webview
        .invoke_handler(|_webview, _arg| Ok(())) // Handle messages from the webview
        .build()
        .unwrap();

    let mut tab_memory = TabMemory::new();
    let mut firewall = Firewall::new();
    let mut protocol_handler = ProtocolHandler::new();
    let mut plugin_sandbox = PluginSandbox::new();
    let mut tab_snapshot = TabSnapshot::new();

    // Register custom protocols
    protocol_handler.register_protocol("vaelix".to_string(), Box::new(|data| {
        // Handle vaelix protocol
        format!("Handling vaelix protocol with data: {}", data)
    }));
    protocol_handler.register_protocol("vz".to_string(), Box::new(|data| {
        // Handle vz protocol
        format!("Handling vz protocol with data: {}", data)
    }));

    // Example of adding a tab to memory
    tab_memory.add_tab("tab1".to_string(), "Content of tab 1".to_string());

    // Example of adding a firewall rule
    firewall.add_rule("tab1".to_string(), "block ads".to_string());

    // Example of running a plugin
    plugin_sandbox.register_plugin("example_plugin".to_string(), Box::new(|| {
        "Plugin output".to_string()
    }));

    // Example of creating a tab snapshot
    let snapshot = tab_snapshot.create_snapshot("tab1", "Content of tab 1");

    // Example of handling a protocol
    if let Some(response) = protocol_handler.handle_protocol("vaelix", "example data".to_string()) {
        println!("Protocol response: {}", response);
    }

    webview.run().unwrap();
}
