# Vaelix Browser Documentation
*Last updated: June 15, 2025*

## Overview
Vaelix is a privacy-focused web browser built with Rust, emphasizing EU law compliance and user privacy protection.

## Documentation Sections

### [Architecture](architecture/overview.md)
- [HTML Engine](architecture/html-engine.md)
- [CSS Engine](architecture/css-engine.md)
- [Privacy Features](architecture/privacy.md)

### [API Documentation](api/core.md)
- [Tiamat Core](api/core.md)
- [Shell Interface](api/shell.md)
- [UI Components](api/ui.md)
- [Privacy Module](api/privacy.md)
- [Legal Compliance](api/law.md)

### [Internals](internals/parsing.md)
- [HTML/CSS Parsing](internals/parsing.md)
- [Rendering Pipeline](internals/rendering.md)
- [Extension System](internals/extensions.md)

### [User Guide](user-guide/getting-started.md)
- [Getting Started](user-guide/getting-started.md)
- [Features](user-guide/features.md)
- [Privacy Settings](user-guide/privacy.md)

### [Legal Documentation](legal/compliance.md)
- [GDPR Compliance](legal/gdpr.md)
- [ePrivacy Directive](legal/eprivacy.md)

## Building Documentation
To build the documentation locally:

```bash
cargo doc --no-deps --document-private-items
```

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to Vaelix.
