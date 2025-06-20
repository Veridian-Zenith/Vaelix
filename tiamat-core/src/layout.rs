use markup5ever_rcdom::{Handle, NodeData, RcDom};
use std::collections::HashMap;

/// Represents a box in the layout
#[derive(Debug, Clone)]
pub struct Box {
    /// The element this box represents
    pub element: Handle,
    /// The content width of the box
    pub content_width: f32,
    /// The content height of the box
    pub content_height: f32,
    /// The padding of the box
    pub padding: (f32, f32, f32, f32),
    /// The border of the box
    pub border: (f32, f32, f32, f32),
    /// The margin of the box
    pub margin: (f32, f32, f32, f32),
    /// The computed width of the box
    pub width: f32,
    /// The computed height of the box
    pub height: f32,
    /// The x position of the box
    pub x: f32,
    /// The y position of the box
    pub y: f32,
}

/// Represents a style for an element
#[derive(Debug, Clone)]
pub struct Style {
    /// The display type (e.g., block, inline, none)
    pub display: String,
    /// The width of the element
    pub width: Option<String>,
    /// The height of the element
    pub height: Option<String>,
    /// The padding of the element
    pub padding: (String, String, String, String),
    /// The border of the element
    pub border: (String, String, String, String),
    /// The margin of the element
    pub margin: (String, String, String, String),
}

/// The layout engine
pub struct LayoutEngine {
    /// The root element of the document
    pub root: Handle,
    /// The styles for each element
    pub styles: HashMap<Handle, Style>,
    /// The computed boxes for each element
    pub boxes: HashMap<Handle, Box>,
}

impl LayoutEngine {
    /// Creates a new layout engine
    pub fn new(root: Handle) -> Self {
        LayoutEngine {
            root,
            styles: HashMap::new(),
            boxes: HashMap::new(),
        }
    }

    /// Sets the style for an element
    pub fn set_style(&mut self, element: Handle, style: Style) {
        self.styles.insert(element, style);
    }

    /// Calculates the layout for the document
    pub fn layout(&mut self) {
        self.calculate_boxes(&self.root);
        self.position_boxes(&self.root, 0.0, 0.0);
    }

    /// Calculates the box for an element and its children
    fn calculate_boxes(&mut self, element: &Handle) {
        if let Some(style) = self.styles.get(element) {
            let mut r#box = Box {
                element: element.clone(),
                content_width: 0.0,
                content_height: 0.0,
                padding: (0.0, 0.0, 0.0, 0.0),
                border: (0.0, 0.0, 0.0, 0.0),
                margin: (0.0, 0.0, 0.0, 0.0),
                width: 0.0,
                height: 0.0,
                x: 0.0,
                y: 0.0,
            };

            // Calculate content size
            match &style.display.as_str() {
                "block" => {
                    // For block elements, calculate content size based on children
                    for child in element.children.borrow().iter() {
                        self.calculate_boxes(child);
                        if let Some(child_box) = self.boxes.get(child) {
                            r#box.content_width = r#box.content_width.max(child_box.width);
                            r#box.content_height += child_box.height;
                        }
                    }
                }
                "inline" => {
                    // For inline elements, calculate content size based on text content
                    if let NodeData::Text { contents } = &element.data {
                        r#box.content_width = contents.borrow().len() as f32 * 8.0; // Simple approximation
                        r#box.content_height = 16.0; // Simple approximation
                    }
                }
                _ => {}
            }

            // Calculate padding, border, and margin
            // (This is a simplified implementation - in a real engine, you would parse CSS values)
            r#box.padding = (
                style.padding.0.parse().unwrap_or(0.0),
                style.padding.1.parse().unwrap_or(0.0),
                style.padding.2.parse().unwrap_or(0.0),
                style.padding.3.parse().unwrap_or(0.0),
            );
            r#box.border = (
                style.border.0.parse().unwrap_or(0.0),
                style.border.1.parse().unwrap_or(0.0),
                style.border.2.parse().unwrap_or(0.0),
                style.border.3.parse().unwrap_or(0.0),
            );
            r#box.margin = (
                style.margin.0.parse().unwrap_or(0.0),
                style.margin.1.parse().unwrap_or(0.0),
                style.margin.2.parse().unwrap_or(0.0),
                style.margin.3.parse().unwrap_or(0.0),
            );

            // Calculate final width and height
            r#box.width = r#box.content_width + r#box.padding.0 + r#box.padding.1 + r#box.border.0 + r#box.border.1;
            r#box.height = r#box.content_height + r#box.padding.2 + r#box.padding.3 + r#box.border.2 + r#box.border.3;

            self.boxes.insert(element.clone(), r#box);
        }

        for child in element.children.borrow().iter() {
            self.calculate_boxes(child);
        }
    }

    /// Positions the boxes in the document
    fn position_boxes(&mut self, element: &Handle, x: f32, y: f32) {
        if let Some(r#box) = self.boxes.get(element) {
            // Update the position of the box
            let mut new_box = r#box.clone();
            new_box.x = x;
            new_box.y = y;
            self.boxes.insert(element.clone(), new_box);

            // Position children
            let mut child_x = x + r#box.margin.3;
            let mut child_y = y + r#box.margin.0;

            for child in element.children.borrow().iter() {
                if let Some(child_box) = self.boxes.get(child) {
                    self.position_boxes(child, child_x, child_y);
                    child_y += child_box.height + child_box.margin.0 + child_box.margin.2;
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::html::HTMLParser;

    #[test]
    fn test_layout_engine() {
        // Create a simple HTML document
        let html = r#"
            <html>
                <body>
                    <div style="display: block; width: 100px; height: 100px;">
                        <p style="display: inline; width: 50px; height: 50px;">Hello</p>
                        <p style="display: inline; width: 50px; height: 50px;">World</p>
                    </div>
                </body>
            </html>
        "#;

        // Parse the HTML
        let parser = HTMLParser::new();
        let dom = parser.parse(html).unwrap();

        // Create the layout engine
        let mut engine = LayoutEngine::new(dom.clone());

        // Set styles for the elements
        engine.set_style(
            dom.clone(),
            Style {
                display: "block".to_string(),
                width: Some("100%".to_string()),
                height: Some("100%".to_string()),
                padding: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
                border: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
                margin: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
            },
        );

        let body = dom.children.borrow()[0].clone();
        engine.set_style(
            body.clone(),
            Style {
                display: "block".to_string(),
                width: Some("100%".to_string()),
                height: Some("100%".to_string()),
                padding: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
                border: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
                margin: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
            },
        );

        let div = body.children.borrow()[0].clone();
        engine.set_style(
            div.clone(),
            Style {
                display: "block".to_string(),
                width: Some("100px".to_string()),
                height: Some("100px".to_string()),
                padding: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
                border: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
                margin: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
            },
        );

        let p1 = div.children.borrow()[0].clone();
        engine.set_style(
            p1.clone(),
            Style {
                display: "inline".to_string(),
                width: Some("50px".to_string()),
                height: Some("50px".to_string()),
                padding: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
                border: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
                margin: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
            },
        );

        let p2 = div.children.borrow()[1].clone();
        engine.set_style(
            p2.clone(),
            Style {
                display: "inline".to_string(),
                width: Some("50px".to_string()),
                height: Some("50px".to_string()),
                padding: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
                border: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
                margin: ("0".to_string(), "0".to_string(), "0".to_string(), "0".to_string()),
            },
        );

        // Calculate the layout
        engine.layout();

        // Check the computed boxes
        assert!(engine.boxes.contains_key(&dom));
        assert!(engine.boxes.contains_key(&body));
        assert!(engine.boxes.contains_key(&div));
        assert!(engine.boxes.contains_key(&p1));
        assert!(engine.boxes.contains_key(&p2));

        // Check the dimensions of the div
        let div_box = engine.boxes.get(&div).unwrap();
        assert_eq!(div_box.width, 100.0);
        assert_eq!(div_box.height, 100.0);

        // Check the dimensions of the paragraphs
        let p1_box = engine.boxes.get(&p1).unwrap();
        assert_eq!(p1_box.width, 50.0);
        assert_eq!(p1_box.height, 50.0);

        let p2_box = engine.boxes.get(&p2).unwrap();
        assert_eq!(p2_box.width, 50.0);
        assert_eq!(p2_box.height, 50.0);

        // Check the positions of the paragraphs
        assert_eq!(p1_box.x, 0.0);
        assert_eq!(p1_box.y, 0.0);

        assert_eq!(p2_box.x, 50.0);
        assert_eq!(p2_box.y, 0.0);
    }
}
