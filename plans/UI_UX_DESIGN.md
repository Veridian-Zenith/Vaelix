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

## 3. GTK4 & Aero-Glass Implementation

- **Framework:** **GTK4 with Libadwaita** for the shell architecture.
- **Styling:** Custom CSS via `GtkCssProvider` to implement the Aero-glass effect.
- **Translucency & Blur:**
  - Utilizing GTK4's `GskRenderer` capabilities and potentially custom `GskRenderNode` for real-time background blur.
  - On Linux, leveraging compositor features (via Wayland protocols or X11 atoms) to request window-level blur behind the GTK window.
- **Lighting & Shadows:**
  - Standard Libadwaita shadows enhanced with custom CSS for "glow" effects.
  - Amber/Orange (`#FF8C00`) accents applied via GTK's `@theme_selected_bg_color` and custom CSS classes.
- **Borders:** Thin, semi-transparent borders defined in CSS (`rgba(255, 255, 255, 0.1)`).

## 4. Key UI Components (GTK4 Widgets)

### 4.1 Tab Bar

- Implemented using `AdwTabView` or a custom `GtkBox` containing glass-styled buttons.
- Integrated tightly with the header bar (`AdwHeaderBar`).
- Tabs use CSS transitions for opacity shifts when active/inactive.

### 4.2 Address/Omnibar

- Built using `GtkEntry` or `AdwEntryRow` with a custom "pill-shaped" CSS class.
- Autocomplete suggestions presented in a `GtkPopover` or a custom `GtkListView` with Aero-blur backgrounds.
- Privacy indicators using `GtkImage` with amber CSS filters.

### 4.3 Menus & Contexts

- Standard GTK `GMenu` and `GtkPopover` components styled with custom CSS to match the Aero-Dark theme.
- Ensures native accessibility and input handling while maintaining the signature visual style.

## 5. Quality of Life (QOL) Features

- **Customizable Workspaces:** Easily group tabs by task with color-coded boundaries.
- **Keyboard Centric:** Full vim-like keybinding support out of the box (optional).
- **Command Palette:** `Ctrl+Shift+P` (or similar) to access any browser setting or command instantly without clicking through menus.
- **Resource Monitor:** A small, elegant status bar widget showing current RAM and CPU usage of the browser processes.

