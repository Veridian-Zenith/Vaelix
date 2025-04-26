use std::collections::HashMap;

pub struct TabMemory {
    tabs: HashMap<String, String>,
}

impl TabMemory {
    pub fn new() -> Self {
        TabMemory {
            tabs: HashMap::new(),
        }
    }

    pub fn add_tab(&mut self, id: String, content: String) {
        self.tabs.insert(id, content);
    }

    pub fn get_tab(&self, id: &str) -> Option<&String> {
        self.tabs.get(id)
    }

    pub fn remove_tab(&mut self, id: &str) {
        self.tabs.remove(id);
    }
}
