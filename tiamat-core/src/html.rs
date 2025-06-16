//! HTML Parser Module
//!
//! This module implements the HTML5 parsing capabilities for the Tiamat Core engine.
//! It follows the HTML5 specification and provides a robust parsing system with error
//! recovery for malformed HTML content.
//!
//! Key features:
//! - Standards-compliant HTML5 parsing
//! - DOM tree construction
//! - Error recovery for malformed HTML
//! - Element selection by ID/class/tag
//! - Text content extraction
//!
//! Phase 1 Implementation (June 20-23, 2025)

use html5ever::tendril::TendrilSink;
use html5ever::{parse_document, ParseOpts};
use markup5ever_rcdom::{Handle, NodeData, RcDom};
use thiserror::Error;

/// Represents errors that can occur during HTML parsing and DOM operations
#[derive(Error, Debug)]
pub enum HTMLError {
    /// Indicates a failure in the HTML parsing process
    #[error("Failed to parse HTML: {0}")]
    ParseError(String),

    /// Indicates an error during DOM tree traversal
    #[error("DOM traversal error: {0}")]
    DOMError(String),
}

/// Main HTML parser implementation
///
/// Provides methods for parsing HTML strings into a DOM tree and
/// traversing/manipulating the resulting structure.
pub struct HTMLParser;

impl HTMLParser {
    /// Creates a new instance of the HTML parser
    pub fn new() -> Self {
        HTMLParser
    }

    /// Parses the given HTML string and returns the root handle of the DOM tree
    ///
    /// # Errors
    ///
    /// Returns an `HTMLError` if the HTML parsing fails.
    pub fn parse(&self, html: &str) -> Result<Handle, HTMLError> {
        let dom = parse_document(RcDom::default(), ParseOpts::default())
            .from_utf8()
            .read_from(&mut html.as_bytes())
            .map_err(|e| HTMLError::ParseError(e.to_string()))?;

        Ok(dom.document)
    }

    /// Retrieves an element by its ID from the DOM tree
    ///
    /// Performs a recursive search starting from the given root handle.
    ///
    /// # Arguments
    ///
    /// * `root` - The root handle to start the search from
    /// * `id` - The ID of the element to search for
    ///
    /// # Returns
    ///
    /// An `Option<Handle>` which is `Some` if the element is found, or `None` otherwise.
    pub fn get_element_by_id(&self, root: &Handle, id: &str) -> Option<Handle> {
        match &root.data {
            NodeData::Element { attrs, .. } => {
                let attrs = attrs.borrow();
                for attr in attrs.iter() {
                    if attr.name.local.to_string() == "id" && attr.value.to_string() == id {
                        return Some(root.clone());
                    }
                }
            }
            _ => {}
        }

        for child in root.children.borrow().iter() {
            if let Some(element) = self.get_element_by_id(child, id) {
                return Some(element);
            }
        }
        None
    }

    /// Extracts the text content from a given DOM node
    ///
    /// Recursively collects text from text nodes and element children.
    ///
    /// # Arguments
    ///
    /// * `handle` - The handle of the DOM node to extract text from
    ///
    /// # Returns
    ///
    /// A `String` containing the concatenated text content.
    pub fn extract_text(&self, handle: &Handle) -> String {
        let mut text = String::new();

        match &handle.data {
            NodeData::Text { contents } => text.push_str(&contents.borrow()),
            NodeData::Element { .. } => {
                for child in handle.children.borrow().iter() {
                    text.push_str(&self.extract_text(child));
                }
            }
            _ => {}
        }

        text
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_html_parsing() {
        let parser = HTMLParser::new();
        let result = parser.parse("<html><body><h1>Hello</h1></body></html>");
        assert!(result.is_ok());

        if let Ok(dom) = result {
            let text = parser.extract_text(&dom);
            assert_eq!(text, "Hello");
        }
    }

    #[test]
    fn test_element_by_id() {
        let parser = HTMLParser::new();
        let html = r#"
            <html>
                <body>
                    <div id="test">Content</div>
                </body>
            </html>
        "#;
        let dom = parser.parse(html).unwrap();
        let element = parser.get_element_by_id(&dom, "test");
        assert!(element.is_some());
    }

    #[test]
    fn test_text_extraction() {
        let parser = HTMLParser::new();
        let html = "<div>Hello <b>World</b>!</div>";
        let dom = parser.parse(html).unwrap();
        assert_eq!(parser.extract_text(&dom), "Hello World!");
    }

    #[test]
    fn test_malformed_html() {
        let parser = HTMLParser::new();
        let html = "<div>Unclosed";
        let result = parser.parse(html);
        assert!(result.is_ok(), "Parser should handle malformed HTML");
    }
}
