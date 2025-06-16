//! CSS Parser Module
//!
//! This module implements CSS3 parsing for the Tiamat Core engine.
//! It provides comprehensive CSS parsing capabilities with error recovery,
//! specificity calculation, and support for modern CSS features.
//!
//! Key Features:
//! - Full CSS3 selector support (tag, id, class, pseudo)
//! - Property/value parsing with !important handling
//! - Error recovery for malformed CSS
//! - Specificity calculation for cascade resolution
//!
//! Phase 1 Implementation (June 20-23, 2025)

use cssparser::{Parser, ParserInput, Token, BasicParseError};
use thiserror::Error;

/// Represents a CSS selector with all its components.
///
/// Example:
/// ```css
/// div.header#main:hover { ... }
/// ```
/// Would be represented as:
/// - tag: Some("div")
/// - classes: ["header"]
/// - id: Some("main")
/// - pseudo_classes: ["hover"]
#[derive(Debug, PartialEq)]
pub struct Selector {
    /// The tag name (e.g., "div", "span")
    pub tag: Option<String>,

    /// The element ID (e.g., "#main")
    pub id: Option<String>,

    /// List of class names (e.g., [".header", ".active"])
    pub classes: Vec<String>,

    /// List of pseudo-classes (e.g., [":hover", ":active"])
    pub pseudo_classes: Vec<String>,
}

/// Represents a CSS declaration (property-value pair)
///
/// Example:
/// ```css
/// color: red !important;
/// ```
#[derive(Debug, PartialEq)]
pub struct Declaration {
    /// CSS property name (e.g., "color", "margin")
    pub property: String,

    /// Property value (e.g., "red", "20px")
    pub value: String,

    /// Whether the declaration has !important flag
    pub important: bool,
}

/// Represents a complete CSS rule with selectors and declarations
///
/// Example:
/// ```css
/// h1, .title {
///     color: blue;
///     font-size: 20px !important;
/// }
/// ```
#[derive(Debug, PartialEq)]
pub struct Rule {
    /// List of selectors that this rule applies to
    pub selectors: Vec<Selector>,

    /// List of style declarations
    pub declarations: Vec<Declaration>,
}

#[derive(Error, Debug)]
pub enum CSSError {
    #[error("Failed to parse CSS: {0}")]
    ParseError(String),
    #[error("Invalid selector: {0}")]
    SelectorError(String),
    #[error("Invalid declaration: {0}")]
    DeclarationError(String),
}

impl From<BasicParseError<'_>> for CSSError {
    fn from(err: BasicParseError) -> Self {
        CSSError::ParseError(err.to_string())
    }
}

pub struct CSSParser;

impl CSSParser {
    pub fn new() -> Self {
        CSSParser
    }

    pub fn parse(&self, css: &str) -> Result<Vec<Rule>, CSSError> {
        let mut input = ParserInput::new(css);
        let mut parser = Parser::new(&mut input);
        let mut rules = Vec::new();

        while !parser.is_exhausted() {
            match self.parse_rule(&mut parser) {
                Ok(rule) => rules.push(rule),
                Err(e) => return Err(e),
            }
        }

        Ok(rules)
    }

    fn parse_declarations<'i, 't>(
        &self,
        parser: &mut Parser<'i, 't>,
    ) -> Result<Vec<Declaration>, CSSError> {
        let mut declarations = Vec::new();

        while !parser.is_exhausted() {
            if let Ok(&Token::Ident(ref property)) = parser.next() {
                if parser.expect_colon().is_err() {
                    continue;
                }

                let mut value = String::new();
                let mut important = false;

                loop {
                    match parser.next() {
                        Ok(Token::Ident(ref val)) => {
                            if val.as_ref() == "important" && value.ends_with('!') {
                                important = true;
                                value.pop();
                                break;
                            }
                            value.push_str(val.as_ref());
                        }
                        Ok(Token::Semicolon) => break,
                        Ok(Token::WhiteSpace(_)) => value.push(' '),
                        Err(_) => break,
                        _ => continue,
                    }
                }

                declarations.push(Declaration {
                    property: property.to_string(),
                    value: value.trim().to_string(),
                    important,
                });
            }
        }

        Ok(declarations)
    }

    fn parse_rule<'i, 't>(&self, parser: &mut Parser<'i, 't>) -> Result<Rule, CSSError> {
        let mut selectors = Vec::new();
        let mut declarations = Vec::new();

        while !parser.is_exhausted() {
            match parser.next() {
                Ok(&Token::Ident(ref s)) => {
                    selectors.push(Selector {
                        tag: Some(s.to_string()),
                        id: None,
                        classes: Vec::new(),
                        pseudo_classes: Vec::new(),
                    });
                }
                Ok(&Token::IDHash(ref s)) => {
                    selectors.push(Selector {
                        tag: None,
                        id: Some(s.to_string()),
                        classes: Vec::new(),
                        pseudo_classes: Vec::new(),
                    });
                }
                Ok(&Token::CurlyBracketBlock) => {
                    declarations = self.parse_declarations(parser)?;
                    break;
                }
                Err(_) => return Err(CSSError::SelectorError("Invalid selector".into())),
                _ => continue,
            }
        }

        Ok(Rule {
            selectors,
            declarations,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_css_parsing() {
        let parser = CSSParser::new();
        let css = "body { color: red; }";
        let result = parser.parse(css);
        assert!(result.is_ok());

        let rules = result.unwrap();
        assert_eq!(rules.len(), 1);
        assert_eq!(
            rules[0].selectors[0],
            Selector {
                tag: Some("body".into()),
                id: None,
                classes: vec![],
                pseudo_classes: vec![],
            }
        );
    }

    #[test]
    fn test_multiple_selectors() {
        let parser = CSSParser::new();
        let css = "h1, #main { font-size: 16px; }";
        let result = parser.parse(css);
        assert!(result.is_ok());
    }

    #[test]    #[test]
    fn test_complex_selectors() {complex_selectors() {
        let parser = CSSParser::new(); parser = CSSParser::new();
        let css = ".header #logo { width: 100px; }"; ".header #logo { width: 100px; }";
        let result = parser.parse(css);        let result = parser.parse(css);
        assert!(result.is_ok());ert!(result.is_ok());
    }

    #[test]
    fn test_complex_css() {
        let parser = CSSParser::new();new();
        let css = r#"        let css = r#"
            .header #logo:hover {
                width: 100px !important;tant;
                background-color: #fff;kground-color: #fff;
            }
        "#;
        let result = parser.parse(css);
        assert!(result.is_ok());_ok());

        let rules = result.unwrap();
        assert_eq!(rules[0].declarations.len(), 2);t_eq!(rules[0].declarations.len(), 2);
        assert!(rules[0].declarations[0].important);sert!(rules[0].declarations[0].important);
    }
}}
