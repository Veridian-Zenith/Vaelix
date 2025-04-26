pub mod protocols {
    use std::collections::HashMap;

    pub struct ProtocolHandler {
        handlers: HashMap<String, Box<dyn Fn(String) -> String>>,
    }

    impl ProtocolHandler {
        pub fn new() -> Self {
            ProtocolHandler {
                handlers: HashMap::new(),
            }
        }

        pub fn register_protocol(&mut self, protocol: String, handler: Box<dyn Fn(String) -> String>) {
            self.handlers.insert(protocol, handler);
        }

        pub fn handle_protocol(&self, protocol: &str, data: String) -> Option<String> {
            self.handlers.get(protocol).map(|handler| handler(data.clone()))
        }
    }
}
