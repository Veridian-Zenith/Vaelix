use std::collections::HashMap;

pub struct Firewall {
    rules: HashMap<String, Vec<String>>,
}

impl Firewall {
    pub fn new() -> Self {
        Firewall {
            rules: HashMap::new(),
        }
    }

    pub fn add_rule(&mut self, tab_id: String, rule: String) {
        self.rules.entry(tab_id).or_insert_with(Vec::new).push(rule);
    }

    pub fn get_rules(&self, tab_id: &str) -> Option<&Vec<String>> {
        self.rules.get(tab_id)
    }

    pub fn remove_rule(&mut self, tab_id: &str, rule: &str) {
        if let Some(rules) = self.rules.get_mut(tab_id) {
            rules.retain(|r| r != rule);
        }
    }
}
