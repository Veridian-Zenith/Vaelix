---

# 🕸️ Vaelix Browser

*“A privacy-first web browser powered by Tiamat Core”*

---

## 📖 Overview

**Vaelix** is a modern, privacy-first web browser built in **Rust**, engineered to meet **EU data privacy standards**.
With a modular architecture and a custom rendering engine (**Tiamat Core**), Vaelix aims to provide secure, efficient, and user-friendly browsing without sacrificing user rights or freedom.

---

## 🚧 Project Status

* **Current Phase:** Phase 1 – Project Foundation
* **Timeline:** June 15 – July 15, 2025
* **Next Milestone:** Basic HTML/CSS parser implementation

---

## 🧩 Core Components

### 🔥 `tiamat-core/` – Tiamat Core

The rendering and processing heart of Vaelix, offering:

* Full **HTML5/CSS3 rendering engine**
* Privacy-first **network stack**
* Early-stage **extension system**

---

### 🧭 `vaelix-shell/` – Shell Module

Handles browser UI logic:

* Tab and window management
* Navigation logic
* Session persistence

---

### 🎨 `vaelix-ui/` – UI Layer

The visual experience:

* Custom widget system
* Theming support (light/dark + user-defined)
* Accessibility-first design principles

---

### ⚖️ `vaelix-law/` – Legal Compliance Module

EU-centric regulatory support:

* Full **GDPR** compliance logic
* **ePrivacy directive** integration
* Consent and tracking policy enforcement

---

### 🛡️ `vaelix-privacy/` – Privacy & Protection Module

Your digital armor:

* Advanced tracker and ad blocking
* Anti-fingerprinting countermeasures
* DNS-over-HTTPS and sandboxed storage options

---

## 🚀 Getting Started

### 🧰 Prerequisites

Install Rust (2024 Edition):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

---

### 🛠️ Build Instructions

```bash
# Clone the repository
git clone https://github.com/yourusername/Vaelix.git
cd Vaelix

# Build the project
cargo build

# Run tests
cargo test
```

---

## 🧑‍💻 Development & Contribution

* Check out [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) for contribution guidelines.
* Roadmap and development phases are outlined in [`plan.md`](plan.md).

---

## 📝 License

**Dual-licensed** under the **GNU AGPLv3** for community use and the **Veridian Commercial License (VCL 1.0)** for proprietary applications.

See the [LICENSE](LICENSE) file for full details.

---

## ⚖️ Legal Disclaimer

**Veridian Zenith** is a digital label and project organization operated by **Jeremy Matlock**, also known as **Dae Euhwa**.
All works published under this name are the intellectual property of Jeremy Matlock unless otherwise stated.
This browser is designed with EU data law compliance in mind but does not constitute legal certification or a legal guarantee.

---

© 2025 Veridian Zenith

---
