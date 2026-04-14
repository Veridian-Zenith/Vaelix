# Vaelix UI/UX Design Specification

## 1. Design Philosophy

The Vaelix UI aims to combine the nostalgic, high-fidelity visual depth of Windows 7 Ultimate's Aero-glass with a modern, high-contrast dark mode tailored for OLED/AMOLED displays. The design prioritizes "Quality of Life" (QOL), ensuring the interface is unobtrusive but highly responsive and visually striking.

## 2. Color Palette & Theming

- **Base Backgrounds:** True Black (`#000000`) to leverage OLED pixel turn-off for deep contrast and battery savings.
- **Surfaces/Cards:** Extremely dark grays (`#0A0A0A` to `#121212`) for depth.
- **Accents (The "Ember" Palette):**
  - Primary Action/Highlight: Deep Amber (`#FF8C00`)
  - Hover States/Secondary: Bright Orange (`#FFA500`)
  - Error/Critical: Crimson Red (`#D22B2B`)
- **Text:** High contrast Off-White (`#E0E0E0`) for primary text, dimmed gray (`#888888`) for secondary text.

## 3. Aero-Glass Dark Implementation

- **Translucency & Blur:** Utilizing custom shaders to implement real-time Gaussian blur with an additive noise layer to simulate physical frosted glass.
- **Lighting & Shadows:**
  - Subtle drop shadows around overlapping UI elements.
  - "Glow" effects triggered by mouse proximity (hover states) using the amber/orange accent colors.
- **Borders:** Thin, semi-transparent borders with a slight specular highlight to define window and tab edges without being visually heavy.

## 4. Key UI Components

### 4.1 Tab Bar

- Integrated tightly with the operating system window frame to maximize screen real-estate.
- Tabs have a sleek, glass-like appearance that becomes more opaque when active.
- Unloaded/Background tabs are visually dimmed.

### 4.2 Address/Omnibar

- Floating, pill-shaped design with a slight inner shadow.
- Highly responsive autocomplete suggestions with distinct typography for history vs. search results.
- Built-in privacy indicators (Lock icon, tracker blockers) that glow amber when active.

### 4.3 Menus & Contexts

- Right-click and main application menus feature the signature dark-glass blur.
- High-performance custom rendering to ensure 0-millisecond latency upon interaction.

## 5. Quality of Life (QOL) Features

- **Customizable Workspaces:** Easily group tabs by task with color-coded boundaries.
- **Keyboard Centric:** Full vim-like keybinding support out of the box (optional).
- **Command Palette:** `Ctrl+Shift+P` (or similar) to access any browser setting or command instantly without clicking through menus.
- **Resource Monitor:** A small, elegant status bar widget showing current RAM and CPU usage of the browser processes.
