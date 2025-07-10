//! DOM Tree for Vaelix

#[derive(Debug, Clone, PartialEq)]
pub struct DomNode {
    pub tag: Option<String>,
    pub attributes: Vec<(String, String)>,
    pub children: Vec<DomNode>,
    pub text: Option<String>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct DomTree {
    pub root: DomNode,
}

impl DomTree {
    pub fn new(root: DomNode) -> Self {
        DomTree { root }
    }
}
