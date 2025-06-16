# Contributing to Vaelix
*Last Updated: June 15, 2025*

## Development Setup

### Requirements
- Rust 2024 edition or later
- Cargo package manager
- Git version control
- Linux/Unix environment (recommended)

### Environment Setup
```bash
# Clone repository
git clone https://github.com/yourusername/Vaelix.git
cd Vaelix

# Install dependencies
cargo build
```

## Project Structure

### Core Modules
- `tiamat-core/`: HTML/CSS rendering engine
- `vaelix-shell/`: Browser shell and tab management
- `vaelix-ui/`: User interface components
- `vaelix-law/`: Legal compliance features
- `vaelix-privacy/`: Privacy protection features

### Documentation
- `docs/`: Project documentation
- `examples/`: Usage examples
- `tests/`: Integration tests

## Development Workflow

### Branching Strategy
- `main`: Stable releases
- `develop`: Development branch
- `feature/*`: New features
- `fix/*`: Bug fixes

### Commit Guidelines
- Use semantic commit messages
- Reference issues where applicable
- Keep commits focused and atomic

### Testing
```bash
# Run all tests
cargo test

# Run specific module tests
cargo test -p tiamat-core
```

## Code Style

### Rust Guidelines
- Follow Rust 2024 idioms
- Use `rustfmt` for formatting
- Run `clippy` for linting

### Documentation
- Document all public APIs
- Include examples in doc comments
- Keep README.md updated

## Review Process

1. Create feature branch
2. Write tests
3. Implement changes
4. Update documentation
5. Submit pull request
6. Address review comments

## Getting Help

- Check existing issues
- Join our Discord server
- Read the documentation

## License

By contributing, you agree to license your work under the project's MIT license.
