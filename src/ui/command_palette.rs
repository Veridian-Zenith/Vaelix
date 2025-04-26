use dioxus::prelude::*;
use web_view::*;

pub fn command_palette(cx: Scope) -> Element {
    let mut input = use_state(&cx, || String::new());
    let mut commands = vec![
        "Open URL",
        "Go Back",
        "Go Forward",
        "Reload",
        "Close Tab",
    ];

    cx.render(rsx!(
        div {
            input {
                id: "command",
                placeholder: "Enter command",
                value: "{input}",
                oninput: |evt| input.set(evt.value.clone()),
                onkeypress: |evt| {
                    if evt.key == "Enter" {
                        // Handle command execution
                        match input.get().as_str() {
                            "Open URL" => {
                                // Open URL command
                            }
                            "Go Back" => {
                                // Go Back command
                            }
                            "Go Forward" => {
                                // Go Forward command
                            }
                            "Reload" => {
                                // Reload command
                            }
                            "Close Tab" => {
                                // Close Tab command
                            }
                            _ => {
                                // Unknown command
                            }
                        }
                    }
                }
            }
            ul {
                commands.iter().map(|command| rsx! {
                    li { "{command}" }
                })
            }
        }
    ))
}
