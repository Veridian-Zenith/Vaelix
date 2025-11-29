# Vaelix Theming Documentation

This document provides comprehensive information about creating, customizing, and managing themes for the Vaelix browser.

## Table of Contents

1. [Theme System Overview](#theme-system-overview)
2. [Seven-Ring Design Philosophy](#seven-ring-design-philosophy)
3. [Edje Theme Structure](#edje-theme-structure)
4. [Color Systems](#color-systems)
5. [Animation Framework](#animation-framework)
6. [Component Styling](#component-styling)
7. [Theme Development Workflow](#theme-development-workflow)
8. [Custom Themes](#custom-themes)
9. [Theme Testing and Validation](#theme-testing-and-validation)
10. [Distribution and Sharing](#distribution-and-sharing)

## Theme System Overview

Vaelix themes are built using Edje, a powerful declarative UI system from the Enlightenment Foundation Libraries. Themes define the visual appearance, behavior, and animations of all browser interface elements.

### Theme Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Theme Manager                        │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐ │
│  │ Theme Parser │  │ Color Engine │  │ Animation Engine│ │
│  └──────────────┘  └──────────────┘  └─────────────────┘ │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────┐
│              Edje Runtime Engine                       │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐ │
│  │   Parts      │  │  Programs    │  │  Transitions    │ │
│  │  (geometry)  │  │(behavior)    │  │  (animations)   │ │
│  └──────────────┘  └──────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Theme Components

**Core Files:**
- `.edc` files: Theme definitions
- `.edj` files: Compiled themes
- Assets: Fonts, images, icons, sounds
- Data: Color palettes, spacing, typography

**Design Elements:**
- **Rings**: Circular decorative elements
- **Runic Glyphs**: Symbolic UI indicators
- **Particle Effects**: Dynamic visual enhancements
- **Color Gradients**: Smooth transitions between colors
- **Animation States**: Interactive feedback systems

## Seven-Ring Design Philosophy

The Seven-Ring aesthetic is inspired by elven craftsmanship and the concept of seven interconnected systems:

### The Seven Systems

1. **UI Ring**: Primary interface elements and navigation
2. **Render Ring**: Web content display and frame handling
3. **Orchestration Ring**: Component coordination and management
4. **Scripting Ring**: Plugin and extension visual integration
5. **Theming Ring**: Style and appearance customization
6. **Permission Ring**: Security indicators and status displays
7. **Extensibility Ring**: Plugin UI and custom integrations

### Design Principles

**Visual Hierarchy:**
- **Primary Rings**: Large, prominent elements with gold accents
- **Secondary Rings**: Medium-sized elements with neon highlights
- **Tertiary Rings**: Small decorative elements for visual interest

**Color Psychology:**
- **Void Black** (#0b0b0f): Stability and focus
- **Elven Gold** (#d4af37): Authority and importance
- **Neon Fuchsia** (#9b32ff): Innovation and interactivity
- **Crystal White** (#f8f8ff): Clarity and readability

**Spatial Relationships:**
- Concentric layouts emphasizing order
- Organic flowing connections between rings
- Balanced asymmetry for dynamic interest
- Negative space for breathability

## Edje Theme Structure

### Basic Edje File Structure

```edc
/* Theme file: sevenring.edc */

fonts {
   font: "DejaVuSans.ttf" "DejaVu Sans";
   font: "RunicSymbols.ttf" "Runic";
}

/* Global color palette */
color_classes {
   color_class "base" 0.05 0.05 0.06 1.0;      /* Void Black */
   color_class "accent" 0.83 0.69 0.22 1.0;    /* Elven Gold */
   color_class "neon" 0.61 0.19 1.0 1.0;       /* Neon Fuchsia */
   color_class "text" 0.97 0.97 1.0 1.0;       /* Crystal White */
   color_class "background" 0.043 0.043 0.047 1.0; /* Dark Gray */
}

/* Images and textures */
images {
   image: "ring_texture.png" COMP;
   image: "runic_glyphs.png" COMP;
   image: "particle_spark.png" COMP;
}

/* Collections of UI groups */
collections {
   /* Window and container groups */
   group {
      name: "sieben/main_window";
      parts { /* ... */ }
      programs { /* ... */ }
   }

   /* Browser chrome groups */
   group {
      name: "sieben/address_bar";
      parts { /* ... */ }
      programs { /* ... */ }
   }

   /* Tab management groups */
   group {
      name: "sieben/tab_container";
      parts { /* ... */ }
      programs { /* ... */ }
   }

   /* Widget groups */
   group {
      name: "sieben/button";
      parts { /* ... */ }
      programs { /* ... */ }
   }
}
```

### Part Definition

```edc
part {
   name: "base_rect";           /* Part name */
   type: RECT;                  /* Part type */

   /* Position and size */
   clip_to: "clip_base";        /* Clip to another part */

   description {
      state: "default" 0.0;     /* State name and value */

      /* Geometry */
      min: 100 40;              /* Minimum size */
      max: -1 -1;               /* Maximum size (-1 = unlimited) */
      fixed: 0 1;               /* Fixed width/height */
      align: 0.5 0.5;           /* Alignment within container */

      /* Visual properties */
      color: 0.05 0.05 0.06 255;  /* RGBA color */
      color_class: "base";      /* Use color class */

      /* Border and outline */
      border: 2 2 2 2;          /* Border thickness */
      border_color: 0.83 0.69 0.22 255;  /* Gold border */

      /* Fill properties */
      fill: "ring_texture.png" 160 0 64 64 0 0;  /* Texture fill */
      fill_smooth: 1;           /* Smooth scaling */
   }

   description {
      state: "active" 0.0;      /* Alternative state */
      inherit: "default" 0.0;   /* Inherit from default state */

      /* Modify properties for active state */
      color: 0.61 0.19 1.0 255; /* Neon color */
      scale: 1.1;               /* Scale factor */

      /* Animation properties */
      rel1.offset: 2 2;         /* Relative position offset */
      rel2.offset: -2 -2;
   }
}
```

### Program Definition

```edc
program {
   name: "activate_ring";       /* Program name */
   signal: "mouse,clicked,*";   /* Trigger signal */
   source: "*";                 /* Signal source */

   /* State transitions */
   action: STATE_SET "active" 0.0;  /* Set to active state */
   transition: LINEAR 0.3;          /* Linear transition over 0.3s */

   /* Conditional execution */
   filter: "state" "default";   /* Only run if in default state */

   /* Multiple actions */
   action: SIGNAL_EMIT "ring_activated" "sieben";  /* Emit custom signal */
   after: "ring_glow";          /* Chain to another program */
}

program {
   name: "ring_glow";
   action: STATE_SET "glow" 0.0;
   transition: SINUSOIDAL 0.5;

   /* Particle effect */
   action: SIGNAL_EMIT "spawn_particles" "sieben";
}
```

## Color Systems

### Primary Color Palette

```edc
color_classes {
   /* Base foundation colors */
   color_class "void_black" 0.043 0.043 0.047 1.0;     /* #0b0b0f */
   color_class "deep_void" 0.024 0.024 0.027 1.0;      /* #06060b */
   color_class "abyss_depth" 0.011 0.011 0.016 1.0;    /* #03030f */

   /* Elven gold accents */
   color_class "elven_gold" 0.831 0.686 0.216 1.0;     /* #d4af37 */
   color_class "royal_gold" 0.922 0.820 0.412 1.0;     /* #ebd06a */
   color_class "ancient_gold" 0.671 0.522 0.024 1.0;   /* #ab8f06 */
   color_class "gold_highlight" 1.0 0.949 0.627 1.0;  /* #fff2a0 */

   /* Neon fuchsia highlights */
   color_class "neon_fuchsia" 0.612 0.188 1.0 1.0;     /* #9b30ff */
   color_class "plasma_pink" 1.0 0.361 0.698 1.0;      /* #ff5cb2 */
   color_class "mystic_violet" 0.459 0.157 0.788 1.0;  /* #7528c8 */
   color_class "electric_purple" 0.722 0.420 1.0 1.0;  /* #b86bff */

   /* Crystal whites for readability */
   color_class "crystal_white" 0.973 0.973 0.976 1.0;  /* #f8f8f8 */
   color_class "silver_moon" 0.839 0.839 0.847 1.0;    /* #d6d6d8 */
   color_class "pearl_shimmer" 0.957 0.957 0.965 1.0;  /* #f4f4f6 */
   color_class "frost_white" 0.976 0.976 0.980 1.0;    /* #f9f9fa */
}
```

### State-Based Color Mapping

```edc
color_classes {
   /* Default state colors */
   color_class "tab_default" 0.059 0.059 0.063 1.0;    /* Dark base */
   color_class "tab_active" 0.831 0.686 0.216 1.0;    /* Gold accent */
   color_class "tab_hover" 0.612 0.188 1.0 1.0;       /* Neon highlight */

   /* Button states */
   color_class "button_default" 0.075 0.075 0.078 1.0;
   color_class "button_pressed" 0.043 0.043 0.047 1.0;
   color_class "button_hover" 0.612 0.188 1.0 1.0;
   color_class "button_disabled" 0.035 0.035 0.039 0.6;

   /* Text colors */
   color_class "text_primary" 0.973 0.973 0.976 1.0;  /* Primary text */
   color_class "text_secondary" 0.839 0.839 0.847 0.7; /* Secondary text */
   color_class "text_muted" 0.059 0.059 0.063 0.5;     /* Muted text */
   color_class "text_warning" 1.0 0.361 0.698 1.0;    /* Warning text */
}
```

### Dynamic Color Functions

```edc
/* Color transitions for interactive feedback */
color_classes {
   color_class "ui_interactive" 0 0 0 0;  /* Will be computed */
}

/* Program to compute dynamic colors */
program {
   name: "compute_interactive_colors";
   action: COLOR_CLASS_SET "ui_interactive"
           0.5:0.831:0.686:0.216:1.0  /* Base: Elven Gold */
           0.6:0.612:0.188:1.0:1.0     /* Hover: Neon Fuchsia */
           0.7:1.0:0.949:0.627:1.0     /* Active: Gold Highlight */
           0.0:0.059:0.059:0.063:0.5;  /* Inactive: Muted Gray */
}
```

## Animation Framework

### Basic Animations

```edc
/* Fade in animation */
program {
   name: "fade_in";
   action: STATE_SET "visible" 0.0;
   transition: LINEAR 0.3;
}

/* Scale animation */
program {
   name: "scale_up";
   action: STATE_SET "scaled" 0.0;
   transition: SINUSOIDAL 0.2;
   target: "scale_part";
}

/* Rotation animation for rings */
program {
   name: "ring_rotation";
   action: STATE_SET "rotated" 0.0;
   transition: LINEAR 0.5;
   target: "rotatable_part";
}

/* Particle emission */
program {
   name: "emit_spark_particles";
   action: SIGNAL_EMIT "spawn_spark" "particle_system";

   /* Spawn multiple particles with delay */
   after: "emit_spark_particles";
   in: 0.1 0.1;  /* Min/max delay */
}
```

### Complex Animation Sequences

```edc
/* Ring activation sequence */
program {
   name: "activate_ring_sequence";
   signal: "mouse,down,1";
   source: "ring_base";

   /* Step 1: Immediate feedback */
   action: STATE_SET "pressed" 0.0;
   transition: LINEAR 0.05;

   /* Step 2: Visual feedback */
   after: "ring_visual_feedback";
   in: 0.05 0.05;

   /* Step 3: Release animation */
   after: "ring_release";
   in: 0.15 0.15;
}

program {
   name: "ring_visual_feedback";
   action: STATE_SET "active" 0.0;
   transition: SINUSOIDAL 0.2;

   /* Start particle effect */
   after: "ring_particle_effect";
}

program {
   name: "ring_release";
   action: STATE_SET "default" 0.0;
   transition: SINUSOIDAL 0.3;
}
```

### Particle System Integration

```edc
/* Particle definition */
part {
   name: "particle_emitter";
   type: PARTICLE;

   particle {
      description {
         state: "default" 0.0;

         /* Particle properties */
         count: 20;
         lifetime: 1.5;
         lifetime_variance: 0.5;

         /* Emission shape */
         emit_func: POINT;
         emit_particle: "spark";

         /* Initial velocity and direction */
         velocity: 50 100;
         velocity_mode: RANDOM;
         angle: 0 360;
         angle_mode: RANDOM;

         /* Visual properties */
         color: 0.612 0.188 1.0 1.0;  /* Neon fuchsia */
         color_variance: 0.2 0.2 0.2 0.0;
         size: 2 6;
         size_mode: RANDOM;
      }
   }
}
```

## Component Styling

### Address Bar

```edc
group {
   name: "sieben/address_bar";

   parts {
      /* Background bar */
      part {
         name: "bar_background";
         type: RECT;

         description {
            state: "default" 0.0;
            min: 400 32;
            align: 0.5 0.5;
            color: 0.059 0.059 0.063 1.0;

            /* Subtle border */
            border: 1 1 1 1;
            border_color: 0.043 0.043 0.047 1.0;
            border_join: ROUND;
         }

         description {
            state: "focus" 0.0;
            inherit: "default" 0.0;
            color_class: "accent";
            border_color: 0.831 0.686 0.216 1.0;
         }
      }

      /* Decorative ring accent */
      part {
         name: "accent_ring";
         type: RECT;
         clip_to: "bar_background";

         description {
            state: "default" 0.0;
            rel1.offset: -2 -2;
            rel2.offset: 1 1;
            color: 0 0 0 0;  /* Transparent */

            /* Subtle ring effect */
            border: 2 2 2 2;
            border_color: 0.831 0.686 0.216 0.3;
         }

         description {
            state: "active" 0.0;
            border_color: 0.831 0.686 0.216 1.0;
            transition: SINUSOIDAL 0.3;
         }
      }

      /* URL text area */
      part {
         name: "url_text";
         type: TEXT;
         clip_to: "bar_background";

         description {
            state: "default" 0.0;
            rel1.offset: 10 6;
            rel2.offset: -10 -6;
            align: 0.0 0.5;
            text {
               text_class: "address_bar";
               text: "Enter URL...";
               font: "DejaVu Sans";
               size: 14;
               color_class: "text_secondary";
               min: 1 1;
               max: 1 1;
               ellipsis: -1;
            }
         }

         description {
            state: "focus" 0.0;
            text {
               color_class: "text_primary";
            }
         }
      }
   }

   programs {
      /* Focus handling */
      program {
         name: "gain_focus";
         signal: "address_bar,gain_focus";
         source: "sieben";
         action: STATE_SET "focus" 0.0;
         transition: SINUSOIDAL 0.2;
      }

      program {
         name: "lose_focus";
         signal: "address_bar,lose_focus";
         source: "sieben";
         action: STATE_SET "default" 0.0;
         transition: SINUSOIDAL 0.2;
      }

      /* Ring accent animation */
      program {
         name: "activate_ring";
         signal: "mouse,clicked,1";
         source: "*";
         action: STATE_SET "active" 0.0;
         transition: SINUSOIDAL 0.3;

         after: "reset_ring";
         in: 0.3 0.3;
      }

      program {
         name: "reset_ring";
         action: STATE_SET "default" 0.0;
         transition: SINUSOIDAL 0.3;
      }
   }
}
```

### Tab Container

```edc
group {
   name: "sieben/tab_container";

   parts {
      /* Container background */
      part {
         name: "container_bg";
         type: RECT;

         description {
            state: "default" 0.0;
            min: 800 32;
            align: 0.5 0.0;
            color: 0.043 0.043 0.047 1.0;
            border: 0 0 1 0;
            border_color: 0.059 0.059 0.063 1.0;
         }
      }

      /* Individual tab slots */
      part {
         name: "tab_slot_1";
         type: RECT;

         description {
            state: "default" 0.0;
            rel1.relative: 0.0 0.0;
            rel2.relative: 0.2 1.0;
            color: 0.043 0.043 0.047 1.0;
         }

         description {
            state: "active" 0.0;
            color: 0.831 0.686 0.216 1.0;  /* Gold for active tab */
         }
      }

      /* Tab content */
      part {
         name: "tab_content_1";
         type: TEXT;
         clip_to: "tab_slot_1";

         description {
            state: "default" 0.0;
            rel1.offset: 10 6;
            rel2.offset: -30 -6;
            text {
               text_class: "tab_title";
               text: "New Tab";
               font: "DejaVu Sans";
               size: 12;
               color_class: "text_secondary";
               ellipsis: -1;
            }
         }

         description {
            state: "active" 0.0;
            text {
               color_class: "text_primary";
            }
         }
      }

      /* Close button */
      part {
         name: "tab_close_1";
         type: RECT;
         clip_to: "tab_slot_1";

         description {
            state: "default" 0.0;
            rel1.relative: 0.75 0.2;
            rel2.relative: 0.9 0.8;
            color: 0.059 0.059 0.063 1.0;
            border: 1 1 1 1;
            border_color: 0.043 0.043 0.047 1.0;
            border_join: ROUND;
         }

         description {
            state: "hover" 0.0;
            color: 1.0 0.361 0.698 1.0;  /* Pink hover */
            transition: LINEAR 0.2;
         }
      }
   }
}
```

## Theme Development Workflow

### Setting Up Development Environment

```bash
#!/bin/bash
# Setup theme development environment

# Install development tools
sudo dnf install -y edje-utils efl-devel

# Create theme project structure
mkdir -p themes/my-theme/{src,assets,build}

# Set up Edje compilation environment
export EDJE_CC="/usr/bin/edje_cc"
export EDJE_CACHE_DIR="$HOME/.cache/edje"
export EDJE_USER_DATA_DIR="$HOME/.local/share/edje"

# Create build script
cat > themes/my-theme/build.sh << 'EOF'
#!/bin/bash
set -euo pipefail

THEME_NAME="my-theme"
SRC_FILE="src/${THEME_NAME}.edc"
BUILD_DIR="build"

echo "Building theme ${THEME_NAME}..."

# Clean build directory
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Compile Edje theme
edje_cc \
    -id "assets" \
    -fd "assets" \
    -o "${BUILD_DIR}/${THEME_NAME}.edj" \
    "${SRC_FILE}"

echo "Theme compiled: ${BUILD_DIR}/${THEME_NAME}.edj"
EOF

chmod +x themes/my-theme/build.sh
```

### Theme Development Cycle

```bash
#!/bin/bash
# Daily theme development workflow

cd themes/my-theme

# 1. Edit theme source
echo "Editing theme source..."
vim src/my-theme.edc

# 2. Compile theme
echo "Compiling theme..."
./build.sh

# 3. Test theme in browser
echo "Testing theme in Vaelix..."
../infra/scripts/reload-theme.sh build/my-theme.edj

# 4. Validate theme
echo "Validating theme..."
edje_cc -id "assets" -fd "assets" -o /dev/null src/my-theme.edc

# 5. Debug theme if needed
if [ $? -ne 0 ]; then
    echo "Theme compilation failed. Check errors above."
    exit 1
fi

echo "Theme development cycle completed successfully!"
```

### Theme Validation

```bash
#!/bin/bash
# Theme validation script

THEME_FILE="$1"
if [ -z "$THEME_FILE" ]; then
    echo "Usage: $0 <theme.edj>"
    exit 1
fi

echo "Validating theme: $THEME_FILE"

# Check file format
echo "Checking file format..."
file "$THEME_FILE"

# Check theme contents
echo "Checking theme contents..."
edje_file -i "$THEME_FILE"

# Check for required groups
echo "Checking required groups..."
REQUIRED_GROUPS=(
    "sieben/main_window"
    "sieben/address_bar"
    "sieben/tab_container"
    "sieben/button"
)

for group in "${REQUIRED_GROUPS[@]}"; do
    echo "Checking for group: $group"
    # Extract and check for group (requires custom validation)
    if ! edje_file -t "$THEME_FILE" | grep -q "group: $group"; then
        echo "WARNING: Missing required group: $group"
    else
        echo "✓ Group found: $group"
    fi
done

# Performance check
echo "Performance validation..."
# Check theme size
size=$(stat -f%z "$THEME_FILE" 2>/dev/null || stat -c%s "$THEME_FILE")
echo "Theme size: $size bytes"

if [ $size -gt 1048576 ]; then  # 1MB limit
    echo "WARNING: Theme is larger than 1MB. Consider optimizing."
else
    echo "✓ Theme size is acceptable"
fi

echo "Theme validation completed."
```

## Custom Themes

### Creating a Custom Theme

```bash
#!/bin/bash
# Create new theme template

THEME_NAME="$1"
if [ -z "$THEME_NAME" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME_DIR="themes/$THEME_NAME"
mkdir -p "$THEME_DIR"/{src,assets/{fonts,images,icons},examples}

# Create theme template
cat > "$THEME_DIR/src/${THEME_NAME}.edc" << EOF
/* Theme: $THEME_NAME */
/* Created: $(date) */

fonts {
   /* Custom fonts for this theme */
   font: "CustomFont-Regular.ttf" "CustomFont";
}

color_classes {
   /* Custom color palette for $THEME_NAME */
   color_class "${THEME_NAME}_primary" 0.0 0.5 1.0 1.0;   /* Blue */
   color_class "${THEME_NAME}_secondary" 1.0 0.0 0.5 1.0; /* Pink */
   color_class "${THEME_NAME}_background" 0.1 0.1 0.1 1.0; /* Dark */
   color_class "${THEME_NAME}_text" 1.0 1.0 1.0 1.0;      /* White */
}

images {
   /* Theme-specific images */
   image: "background.png" COMP;
   image: "icon_set.png" COMP;
}

collections {
   /* Import base theme components */
   \#include "../sevenring/edje_groups.edc"

   /* Custom theme-specific overrides */
   group {
      name: "sieben/custom_override";

      parts {
         part {
            name: "custom_element";
            type: RECT;

            description {
               state: "default" 0.0;
               color_class: "${THEME_NAME}_primary";
            }
         }
      }
   }
}
EOF

# Create theme information
cat > "$THEME_DIR/theme.info" << EOF
name: $THEME_NAME
version: 1.0.0
description: A custom Vaelix theme
author: Your Name
license: MIT
tags: custom, modern, blue
compatibility: Vaelix >= 1.0.0
EOF

# Create example plugin
cat > "$THEME_DIR/examples/theme-example.rkt" << 'EOF'
#lang racket

(require sieben/plugin-api)

;; Example plugin that showcases theme capabilities
(define (plugin-start)
  (register-event-hook! 'theme-changed on-theme-changed)
  (create-theme-demo-ui!))

(define (on-theme-changed theme-name)
  (log-info "Theme changed to:" theme-name))

(define (create-theme-demo-ui!)
  (when (check-permission 'ui-injection)
    (create-widget 'demo-panel
                   #:title "Theme Demo"
                   #:position '(100 100)
                   #:size '(400 300))))
EOF

echo "Custom theme '$THEME_NAME' created in $THEME_DIR"
echo "Next steps:"
echo "1. Edit src/${THEME_NAME}.edc to customize the theme"
echo "2. Add assets to the assets/ directory"
echo "3. Run ./build.sh to compile"
echo "4. Test with ../infra/scripts/reload-theme.sh"
```

### Theme Inheritance

```edc
/* Base theme inheritance */
collections {
   /* Import base SevenRing theme */
   \#include "../sevenring/sevenring_base.edc"

   /* Custom theme modifications */
   group {
      name: "sieben/address_bar";
      alias: "sieben/base_address_bar";  /* Alias to base */

      parts {
         /* Override specific parts */
         part {
            name: "custom_background";
            type: RECT;
            inherit: 1 0.0;  /* Inherit from base part */

            description {
               state: "default" 0.0;
               color_class: "custom_theme_accent";  /* Override color */
            }
         }

         /* Add new decorative elements */
         part {
            name: "decorative_rune";
            type: IMAGE;

            description {
               state: "default" 0.0;
               rel1.relative: 1.0 0.0;
               rel2.relative: 1.0 1.0;
               image.normal: "rune_symbol.png";
               image.tween: "rune_symbol_active.png";
               fill.smooth: 1;
            }
         }
      }

      programs {
         /* Extend base programs */
         program {
            name: "activate_rune";
            signal: "mouse,clicked,1";
            source: "decorative_rune";
            action: IMAGE_TWEEN_SET 1.0;
            transition: SINUSOIDAL 0.3;

            after: "reset_rune";
            in: 0.3 0.3;
         }

         /* Chain to base program */
         program {
            name: "chain_to_base";
            after: "base_address_bar_glow";
         }
      }
   }
}
```

### Theme Configuration

```racket
#lang racket

;; Theme configuration management
#lang racket

(require json)

(define (load-theme-config theme-name)
  (define config-file (format #f "themes/~a/config.json" theme-name))

  (if (file-exists? config-file)
      (with-input-from-file config-file
        (λ () (json-decode (port->string))))
      '()))

(define (save-theme-config theme-name config)
  (define config-file (format #f "themes/~a/config.json" theme-name))

  (with-output-to-file config-file
    (λ () (write (json-encode config)))
    #:exists 'replace))

(define default-theme-config
  '((version . "1.0")
    (colors . ((primary . "#0b0b0f")
               (accent . "#d4af37")
               (neon . "#9b30ff")
               (text . "#f8f8f8")))
    (animations . ((duration . 0.3)
                   (easing . "sinusoidal")))
    (components . ((show-particles . #t)
                   (show-runes . #t)
                   (animation-level . "normal")))))

;; Apply theme configuration
(define (apply-theme-config theme-name)
  (define config (load-theme-config theme-name))
  (when config
    (apply-colors! config)
    (apply-animations! config)
    (apply-components! config)))
```

## Theme Testing and Validation

### Automated Testing

```bash
#!/bin/bash
# Automated theme testing script

THEME_NAME="$1"
if [ -z "$THEME_NAME" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

echo "Running automated tests for theme: $THEME_NAME"

# Test 1: Compilation
echo "Test 1: Compilation"
if ./build.sh; then
    echo "✓ Compilation passed"
else
    echo "✗ Compilation failed"
    exit 1
fi

# Test 2: Required groups
echo "Test 2: Required groups"
REQUIRED_GROUPS=(
    "sieben/main_window"
    "sieben/address_bar"
    "sieben/tab_container"
    "sieben/button"
    "sieben/menu"
    "sieben/dialog"
)

for group in "${REQUIRED_GROUPS[@]}"; do
    if edje_file -i "build/${THEME_NAME}.edj" | grep -q "$group"; then
        echo "✓ Found group: $group"
    else
        echo "✗ Missing group: $group"
        ((fail_count++))
    fi
done

# Test 3: Color classes
echo "Test 3: Color classes"
REQUIRED_COLORS=(
    "base"
    "accent"
    "neon"
    "text"
    "background"
)

for color in "${REQUIRED_COLORS[@]}"; do
    if edje_file -i "build/${THEME_NAME}.edj" | grep -q "color_class $color"; then
        echo "✓ Found color class: $color"
    else
        echo "✗ Missing color class: $color"
        ((fail_count++))
    fi
done

# Test 4: Animations
echo "Test 4: Animation programs"
if edje_file -i "build/${THEME_NAME}.edj" | grep -q "transition:"; then
    echo "✓ Found animations"
else
    echo "✗ No animations found"
    ((fail_count++))
fi

# Test 5: Theme validation
echo "Test 5: Theme validation"
../infra/scripts/validate-theme.sh "build/${THEME_NAME}.edj"

if [ ${fail_count:-0} -eq 0 ]; then
    echo "All tests passed for theme: $THEME_NAME"
    exit 0
else
    echo "Theme testing failed with $fail_count errors"
    exit 1
fi
```

### Manual Testing Procedures

```bash
#!/bin/bash
# Manual theme testing

THEME_FILE="build/$1"
if [ -z "$THEME_FILE" ]; then
    echo "Usage: $0 <theme.edj>"
    exit 1
fi

echo "Manual testing for theme: $THEME_FILE"

# Load theme in browser
echo "Loading theme in Vaelix browser..."
../infra/scripts/load-theme.sh "$THEME_FILE"

# Test procedures
echo "Manual testing checklist:"
echo "□ Theme loads without errors"
echo "□ Address bar displays correctly"
echo "□ Tab container functions properly"
echo "□ Buttons respond to hover and click"
echo "□ Animations play smoothly"
echo "□ Colors render correctly"
echo "□ Text is readable"
echo "□ Layout is responsive"
echo "□ No visual artifacts"
echo "□ Performance is acceptable"

# Interactive testing
echo "Starting interactive testing session..."
read -p "Press Enter to start testing..."
../infra/scripts/start-test-browser.sh "$THEME_FILE"
```

### Performance Testing

```bash
#!/bin/bash
# Theme performance testing

THEME_FILE="$1"
if [ -z "$THEME_FILE" ]; then
    echo "Usage: $0 <theme.edj>"
    exit 1
fi

echo "Performance testing for theme: $THEME_FILE"

# Measure theme load time
echo "Measuring theme load time..."
time (
    ../infra/scripts/load-theme.sh "$THEME_FILE"
)

# Test memory usage
echo "Testing memory usage..."
valgrind --tool=massif \
         --time-unit=ms \
         --massif-out-file=theme_massif.out \
         ../infra/scripts/test-theme.sh "$THEME_FILE"

# Analyze memory usage
ms_print theme_massif.out > theme_memory_analysis.txt
echo "Memory analysis saved to: theme_memory_analysis.txt"

# GPU performance test
echo "Testing GPU performance..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi dmon -s puc -d 1 &
    GPU_MONITOR_PID=$!

    # Run theme test
    ../infra/scripts/test-theme-gpu.sh "$THEME_FILE"

    # Stop GPU monitoring
    kill $GPU_MONITOR_PID

    echo "GPU monitoring stopped"
else
    echo "GPU monitoring not available"
fi

# Animation smoothness test
echo "Testing animation smoothness..."
../infra/scripts/test-animations.sh "$THEME_FILE"

echo "Performance testing completed"
```

## Distribution and Sharing

### Package Creation

```bash
#!/bin/bash
# Create distribution package for theme

THEME_NAME="$1"
if [ -z "$THEME_NAME" ]; then
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME_DIR="themes/$THEME_NAME"
DIST_DIR="dist"
PACKAGE_NAME="${THEME_NAME}-theme"

echo "Creating distribution package: $PACKAGE_NAME"

# Clean dist directory
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Copy theme files
cp -r "$THEME_DIR" "$DIST_DIR/$PACKAGE_NAME"

# Create installation script
cat > "$DIST_DIR/$PACKAGE_NAME/install.sh" << EOF
#!/bin/bash
# Installation script for $THEME_NAME theme

THEME_NAME="$THEME_NAME"
INSTALL_DIR="\$HOME/.vaelix/themes/\$THEME_NAME"

echo "Installing $THEME_NAME theme..."

# Create installation directory
mkdir -p "\$INSTALL_DIR"

# Copy theme files
cp -r src "\$INSTALL_DIR/"
cp -r assets "\$INSTALL_DIR/"
cp theme.info "\$INSTALL_DIR/"
cp *.edj "\$INSTALL_DIR/"

echo "Theme installed to: \$INSTALL_DIR"
echo "To activate: vconfig theme set $THEME_NAME"
EOF

chmod +x "$DIST_DIR/$PACKAGE_NAME/install.sh"

# Create README
cat > "$DIST_DIR/$PACKAGE_NAME/README.md" << EOF
# $THEME_NAME Theme

A custom theme for the Vaelix browser.

## Installation

1. Extract this package
2. Run: \`./install.sh\`
3. Activate: \`vconfig theme set $THEME_NAME\`

## Requirements

- Vaelix browser >= 1.0.0
- Edje theme engine

## Author

Your Name

## License

MIT
EOF

# Create manifest
cat > "$DIST_DIR/$PACKAGE_NAME/manifest.json" << EOF
{
  "name": "$THEME_NAME-theme",
  "version": "1.0.0",
  "description": "Custom Vaelix theme",
  "author": "Your Name",
  "license": "MIT",
  "tags": ["theme", "custom"],
  "compatibility": {
    "vaelix": ">=1.0.0"
  },
  "files": [
    "src/*.edc",
    "assets/**/*",
    "*.edj",
    "theme.info"
  ]
}
EOF

# Create archive
cd "$DIST_DIR"
tar -czf "${PACKAGE_NAME}.tar.gz" "$PACKAGE_NAME"
zip -r "${PACKAGE_NAME}.zip" "$PACKAGE_NAME" > /dev/null

# Generate checksums
sha256sum "${PACKAGE_NAME}.tar.gz" > "${PACKAGE_NAME}.tar.gz.sha256"
sha256sum "${PACKAGE_NAME}.zip" > "${PACKAGE_NAME}.zip.sha256"

echo "Distribution package created:"
echo "- $DIST_DIR/${PACKAGE_NAME}.tar.gz"
echo "- $DIST_DIR/${PACKAGE_NAME}.zip"
echo "- Checksums generated"
```

### Theme Repository

```bash
#!/bin/bash
# Theme repository management

REPO_DIR="theme-repository"
mkdir -p "$REPO_DIR"/{themes,index,upload}

# Create theme index
cat > "$REPO_DIR/index/index.json" << 'EOF'
{
  "repository": {
    "name": "Vaelix Theme Repository",
    "version": "1.0.0",
    "description": "Community-maintained collection of Vaelix themes",
    "maintainer": "Vaelix Team"
  },
  "themes": [
    {
      "name": "sevenring",
      "version": "1.0.0",
      "description": "Default Seven-Ring aesthetic theme",
      "author": "Vaelix Team",
      "license": "OSL-3.0",
      "tags": ["default", "sevenring", "dark"],
      "compatibility": {
        "vaelix": ">=1.0.0"
      },
      "download_url": "themes/sevenring/sevenring-theme.tar.gz",
      "preview_url": "themes/sevenring/preview.png",
      "rating": 4.8,
      "downloads": 1250
    },
    {
      "name": "mystical-dawn",
      "version": "1.0.0",
      "description": "Light theme with mystical accents",
      "author": "Theme Developer",
      "license": "MIT",
      "tags": ["light", "mystical", "day"],
      "compatibility": {
        "vaelix": ">=1.0.0"
      },
      "download_url": "themes/mystical-dawn/mystical-dawn-theme.tar.gz",
      "preview_url": "themes/mystical-dawn/preview.png",
      "rating": 4.2,
      "downloads": 890
    }
  ]
}
EOF

# Upload new theme
upload_theme() {
    local theme_name="$1"
    local theme_file="$2"

    echo "Uploading theme: $theme_name"

    # Validate theme
    ../infra/scripts/validate-theme.sh "$theme_file" || {
        echo "Theme validation failed"
        return 1
    }

    # Copy to repository
    mkdir -p "$REPO_DIR/themes/$theme_name"
    cp "$theme_file" "$REPO_DIR/themes/$theme_name/"

    # Update index
    python3 << EOF
import json
import sys

with open("$REPO_DIR/index/index.json", "r") as f:
    data = json.load(f)

new_theme = {
    "name": "$theme_name",
    "version": "1.0.0",
    "description": "Custom theme",
    "author": "Community Developer",
    "license": "MIT",
    "tags": ["custom"],
    "compatibility": {
        "vaelix": ">=1.0.0"
    },
    "download_url": "themes/$theme_name/$theme_name-theme.tar.gz",
    "preview_url": "themes/$theme_name/preview.png",
    "rating": 0.0,
    "downloads": 0
}

data["themes"].append(new_theme)

with open("$REPO_DIR/index/index.json", "w") as f:
    json.dump(data, f, indent=2)

print("Theme index updated")
EOF

    echo "Theme uploaded successfully"
}

echo "Theme repository management initialized"
echo "Usage:"
echo "  upload_theme <name> <theme-file>"
```

---

*This theming documentation provides comprehensive guidance for creating and managing Vaelix themes. For the latest theming tools and examples, visit our [theme development wiki](https://github.com/veridian-zenith/vaelix/wiki/Theme-Development).*
