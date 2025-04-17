// Entry point for the Vaelix browser

mod renderer;
mod networking;
mod ui;
mod storage;

fn main() {
    println!("Welcome to Vaelix! Initializing browser...");

    // Initialize the UI
    ui::initialize_ui();
}
