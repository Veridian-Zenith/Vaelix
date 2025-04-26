use std::collections::HashMap;

pub struct PluginSandbox {
    plugins: HashMap<String, Box<dyn Fn() -> String>>,
}

impl PluginSandbox {
    pub fn new() -> Self {
        PluginSandbox {
            plugins: HashMap::new(),
        }
    }

    pub fn register_plugin(&mut self, name: String, plugin: Box<dyn Fn() -> String>) {
        self.plugins.insert(name, plugin);
    }

    pub fn run_plugin(&self, name: &str) -> Option<String> {
        self.plugins.get(name).map(|plugin| plugin())
    }
}
