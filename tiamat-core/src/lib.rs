//! Tiamat Core - Main Browser Engine
//!
//! Core functionality includes:
//! - HTML/CSS parsing and rendering
//! - DOM tree management
//! - Layout engine
//! - Protocol handling
//! - JavaScript execution
//!
//! Phase 1 Implementation (June 20-23, 2025)

mod css;
mod html;
mod layout;
mod protocol;

pub use css::CSSParser;
pub use html::HTMLParser;
pub use layout::LayoutEngine;
pub use protocol::{ProtocolHandler, Protocol, RequestConfig};

/// Initializes the Tiamat Core engine
pub fn hello() {
    println!("Tiamat Core initialized - HTML/CSS/Protocol ready.");
}
