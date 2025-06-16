# Vaelix Browser
*A privacy-first web browser powered by Tiamat Core*

## Overview
Vaelix is a modern web browser built with Rust, focusing on privacy protection and EU law compliance. It features a modular architecture with Tiamat Core at its center, providing robust HTML/CSS rendering capabilities.

## Project Status
- **Current Phase**: Phase 1 - Project Foundation
- **Timeline**: June 15 - July 15, 2025
- **Next Milestone**: Basic HTML/CSS Parser Implementation

## Core Components

### Tiamat Core (`tiamat-core/`)
The heart of Vaelix, providing:
- HTML5/CSS3 rendering engine
- Privacy-first network stack
- Extension support system

### Shell Module (`vaelix-shell/`)
Handles browser UI components:
- Tab management
- Window controls
- Navigation system

### UI Layer (`vaelix-ui/`)
Modern interface toolkit:
- Custom widgets
- Theme support
- Accessibility features

### Legal Module (`vaelix-law/`)
EU compliance features:
- GDPR implementation
- ePrivacy directives
- Consent management

### Privacy Module (`vaelix-privacy/`)
Enhanced protection:
- Tracker blocking
- Ad filtering
- Anti-fingerprinting

## Getting Started

### Prerequisites
```bash
# Install Rust (2024 edition)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Building
```bash
# Clone repository
git clone https://github.com/yourusername/Vaelix.git
cd Vaelix

# Build project
cargo build

# Run tests
cargo test
```

## Development

See [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) for development guidelines.
Project roadmap available in [`plan.md`](plan.md).

## License

MIT License - See [`LICENSE`](LICENSE) for details.

