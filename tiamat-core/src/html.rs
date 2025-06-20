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
use html5ever::{parse_document, ParseOpts, tokenizer};
use markup5ever_rcdom::{Handle, NodeData, RcDom, NodeRef};
use thiserror::Error;
use std::borrow::Cow;

/// HTML Tokenizer
///
/// A simple HTML tokenizer that converts HTML input into a stream of tokens.
pub struct HTMLTokenizer {
    /// The input HTML string
    input: String,
    /// The current position in the input
    position: usize,
    /// The current token being processed
    current_token: Option<Token>,
}

#[derive(Debug, PartialEq)]
/// Represents an HTML token
pub enum Token {
    /// A start tag (e.g., `<div>`)
    StartTag(String, Vec<(String, String)>),
    /// An end tag (e.g., `</div>`)
    EndTag(String),
    /// Text content (e.g., "Hello World")
    Text(String),
    /// A comment (e.g., `<!-- comment -->`)
    Comment(String),
    /// A doctype declaration (e.g., `<!DOCTYPE html>`)
    Doctype(String),
    /// An error in the HTML
    Error(String),
}

impl HTMLTokenizer {
    /// Creates a new HTML tokenizer
    pub fn new(input: &str) -> Self {
        HTMLTokenizer {
            input: input.to_string(),
            position: 0,
            current_token: None,
        }
    }

    /// Advances the tokenizer to the next token
    pub fn next_token(&mut self) -> Option<Token> {
        self.current_token = self.tokenize();
        self.current_token.clone()
    }

    /// Tokenizes the input HTML
    fn tokenize(&mut self) -> Option<Token> {
        if self.position >= self.input.len() {
            return None;
        }

        // Skip whitespace
        while self.position < self.input.len() && self.input[self.position..].starts_with(char::is_whitespace) {
            self.position += 1;
        }

        // Check for doctype
        if self.input[self.position..].starts_with("<!DOCTYPE") {
            let end = self.input[self.position..].find('>')?;
            let doctype = &self.input[self.position..self.position + end + 1];
            self.position += end + 1;
            return Some(Token::Doctype(doctype.to_string()));
        }

        // Check for comment
        if self.input[self.position..].starts_with("<!--") {
            let end = self.input[self.position..].find("-->")?;
            let comment = &self.input[self.position + 4..self.position + end];
            self.position += end + 3;
            return Some(Token::Comment(comment.to_string()));
        }

        // Check for tag
        if self.input[self.position..].starts_with('<') {
            if self.input[self.position + 1..].starts_with('/') {
                // End tag
                let end = self.input[self.position + 2..].find('>')?;
                let tag_name = &self.input[self.position + 2..self.position + 2 + end];
                self.position += end + 3;
                return Some(Token::EndTag(tag_name.to_string()));
            } else {
                // Start tag
                let end = self.input[self.position + 1..].find('>')?;
                let tag_content = &self.input[self.position + 1..self.position + 1 + end];
                self.position += end + 2;

                // Parse attributes
                let mut attrs = Vec::new();
                let parts: Vec<&str> = tag_content.split_whitespace().collect();
                if parts.len() > 0 {
                    let tag_name = parts[0];
                    for part in &parts[1..] {
                        let mut attr = part.split('=');
                        let name = attr.next()?.to_string();
                        let value = if let Some(val) = attr.next() {
                            if val.starts_with('"') || val.starts_with('\'') {
                                val[1..val.len() - 1].to_string()
                            } else {
                                val.to_string()
                            }
                        } else {
                            String::new()
                        };
                        attrs.push((name, value));
                    }
                    return Some(Token::StartTag(tag_name.to_string(), attrs));
                }
            }
        }

        // Text content
        let end = self.input[self.position..].find('<');
        let text = if let Some(end) = end {
            &self.input[self.position..self.position + end]
        } else {
            &self.input[self.position..]
        };
        self.position += text.len();
        Some(Token::Text(text.to_string()))
    }
}

impl Iterator for HTMLTokenizer {
    type Item = Token;

    fn next(&mut self) -> Option<Self::Item> {
        self.next_token()
    }
}

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

    /// Builds a DOM tree from HTML tokens
    ///
    /// This method takes a stream of HTML tokens and constructs a DOM tree.
    ///
    /// # Arguments
    ///
    /// * `tokens` - An iterator over HTML tokens
    ///
    /// # Returns
    ///
    /// A `Result` containing the root of the DOM tree or an error.
    pub fn build_dom(&self, tokens: &mut dyn Iterator<Item = Token>) -> Result<Handle, HTMLError> {
        let dom = RcDom::default();
        let mut root = dom.create_element("html", vec![]);
        let mut stack = vec![root.clone()];

        while let Some(token) = tokens.next() {
            match token {
                Token::StartTag(tag_name, attrs) => {
                    let mut element = dom.create_element(&tag_name, attrs);
                    if let Some(parent) = stack.last() {
                        parent.append_child(dom.create_node(element));
                    }
                    stack.push(element);
                }
                Token::EndTag(_) => {
                    if stack.len() > 1 {
                        stack.pop();
                    }
                }
                Token::Text(text) => {
                    if let Some(parent) = stack.last() {
                        parent.append_child(dom.create_text_node(&text));
                    }
                }
                Token::Comment(_) | Token::Doctype(_) | Token::Error(_) => {
                    // Ignore comments, doctypes, and errors for now
                }
            }
        }

        Ok(root)
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

    /// Retrieves an element by its class name from the DOM tree
    ///
    /// Performs a recursive search starting from the given root handle.
    ///
    /// # Arguments
    ///
    /// * `root` - The root handle to start the search from
    /// * `class_name` - The class name of the element to search for
    ///
    /// # Returns
    ///
    /// A `Vec<Handle>` containing all elements with the specified class name.
    pub fn get_elements_by_class(&self, root: &Handle, class_name: &str) -> Vec<Handle> {
        let mut results = Vec::new();

        if let NodeData::Element { attrs, .. } = &root.data {
            let attrs = attrs.borrow();
            for attr in attrs.iter() {
                if attr.name.local.to_string() == "class" {
                    let classes: Vec<&str> = attr.value.to_string().split(' ').collect();
                    if classes.contains(&class_name) {
                        results.push(root.clone());
                    }
                }
            }
        }

        for child in root.children.borrow().iter() {
            results.extend(self.get_elements_by_class(child, class_name));
        }

        results
    }

    /// Retrieves an element by its tag name from the DOM tree
    ///
    /// Performs a recursive search starting from the given root handle.
    ///
    /// # Arguments
    ///
    /// * `root` - The root handle to start the search from
    /// * `tag_name` - The tag name of the element to search for
    ///
    /// # Returns
    ///
    /// A `Vec<Handle>` containing all elements with the specified tag name.
    pub fn get_elements_by_tag(&self, root: &Handle, tag_name: &str) -> Vec<Handle> {
        let mut results = Vec::new();

        if let NodeData::Element { name, .. } = &root.data {
            if name.local.to_string() == tag_name {
                results.push(root.clone());
            }
        }

        for child in root.children.borrow().iter() {
            results.extend(self.get_elements_by_tag(child, tag_name));
        }

        results
    }

    /// Retrieves an element by its data attribute from the DOM tree
    ///
    /// Performs a recursive search starting from the given root handle.
    ///
    /// # Arguments
    ///
    /// * `root` - The root handle to start the search from
    /// * `data_name` - The name of the data attribute to search for
    /// * `data_value` - The value of the data attribute to match
    ///
    /// # Returns
    ///
    /// A `Vec<Handle>` containing all elements with the specified data attribute and value.
    pub fn get_elements_by_data(&self, root: &Handle, data_name: &str, data_value: &str) -> Vec<Handle> {
        let mut results = Vec::new();

        if let NodeData::Element { attrs, .. } = &root.data {
            let attrs = attrs.borrow();
            for attr in attrs.iter() {
                if attr.name.local.to_string().starts_with("data-") {
                    let attr_name = attr.name.local.to_string();
                    if attr_name == data_name && attr.value.to_string() == data_value {
                        results.push(root.clone());
                    }
                }
            }
        }

        for child in root.children.borrow().iter() {
            results.extend(self.get_elements_by_data(child, data_name, data_value));
        }

        results
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

    #[test]
    fn test_dom_builder() {
        let parser = HTMLParser::new();
        let html = "<div><p>Hello</p><p>World</p></div>";
        let mut tokenizer = HTMLTokenizer::new(html);
        let dom = parser.build_dom(&mut tokenizer).unwrap();

        // Check that the root element is a div
        assert_eq!(dom.name.local, "div");

        // Check that there are two children (p elements)
        assert_eq!(dom.children.borrow().len(), 2);

        // Check that the first child is a p element with text "Hello"
        let first_child = &dom.children.borrow()[0];
        assert_eq!(first_child.name.local, "p");
        assert_eq!(parser.extract_text(first_child), "Hello");

        // Check that the second child is a p element with text "World"
        let second_child = &dom.children.borrow()[1];
        assert_eq!(second_child.name.local, "p");
        assert_eq!(parser.extract_text(second_child), "World");
    }
}
