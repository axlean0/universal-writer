---
name: Writer’s Sanctuary
colors:
  surface: '#faf9f7'
  surface-dim: '#dadad8'
  surface-bright: '#faf9f7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3f1'
  surface-container: '#efeeec'
  surface-container-high: '#e9e8e6'
  surface-container-highest: '#e3e2e0'
  on-surface: '#1a1c1b'
  on-surface-variant: '#43474c'
  inverse-surface: '#2f3130'
  inverse-on-surface: '#f1f1ef'
  outline: '#74777d'
  outline-variant: '#c4c6cd'
  surface-tint: '#4e6073'
  primary: '#162839'
  on-primary: '#ffffff'
  primary-container: '#2c3e50'
  on-primary-container: '#96a9be'
  inverse-primary: '#b5c8df'
  secondary: '#496800'
  on-secondary: '#ffffff'
  secondary-container: '#c8f17a'
  on-secondary-container: '#4e6e00'
  tertiary: '#362308'
  on-tertiary: '#ffffff'
  tertiary-container: '#4e381c'
  on-tertiary-container: '#c1a17d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d1e4fb'
  primary-fixed-dim: '#b5c8df'
  on-primary-fixed: '#091d2e'
  on-primary-fixed-variant: '#36485b'
  secondary-fixed: '#c8f17a'
  secondary-fixed-dim: '#add461'
  on-secondary-fixed: '#131f00'
  on-secondary-fixed-variant: '#364e00'
  tertiary-fixed: '#ffddb7'
  tertiary-fixed-dim: '#e3c19b'
  on-tertiary-fixed: '#291802'
  on-tertiary-fixed-variant: '#5a4225'
  background: '#faf9f7'
  on-background: '#1a1c1b'
  surface-variant: '#e3e2e0'
typography:
  display-title:
    fontFamily: Manrope
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-reading:
    fontFamily: Source Serif 4
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 30px
  body-ui:
    fontFamily: Manrope
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 24px
  label-caps:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  sidebar_width: 260px
  container_max_width: 1200px
  grid_gutter: 24px
  section_margin: 48px
  safe_padding: 32px
  stack_sm: 8px
  stack_md: 16px
---

## Brand & Style

The design system is built on the philosophy of **Minimalism and Deep Work**. It is designed specifically for authors, researchers, and creators who require a digital environment that recedes into the background, allowing the written word to take center stage.

The emotional response is one of **calm, clarity, and intellectual focus**. By stripping away unnecessary UI chrome and decorative flourishes, the system mirrors the quiet atmosphere of a physical library or a high-end stationery shop. The visual language utilizes heavy whitespace, precise alignment, and a sophisticated editorial aesthetic to evoke a sense of professional craftsmanship.

## Colors

The palette is rooted in the "Paper and Ink" metaphor. We avoid pure blacks and whites to reduce eye strain during long-form writing sessions.

- **Primary (Ink):** A deep, midnight gray (#2C3E50) used for primary text and iconography.
- **Secondary (Sage):** A muted, organic green (#6B8E23) used sparingly for positive actions like "New Creation" or success states.
- **Neutral (Parchment):** A soft, warm off-white (#F9F8F6) used for the sidebar and global backgrounds to differentiate from the pure white writing surface.
- **Surface:** Pure white (#FFFFFF) is reserved exclusively for active card surfaces and the main writing canvas to signal focus.
- **Borders:** Low-contrast taupe (#E5E1DA) provides structural definition without visual noise.

## Typography

This design system employs a **dual-font strategy**. 

1.  **Manrope (Sans-Serif):** Used for the "Bookshelf" interface, sidebar navigation, search bars, and utility labels. It provides a clean, modern, and highly legible structure for the software's management layer.
2.  **Source Serif 4 (Serif):** Used for the "Books" themselves and the core writing experience. This font is optimized for long-form reading, offering a traditional literary feel that aids focus.

Headlines use tight letter spacing for a modern look, while body text uses a generous 1.6x line height to ensure maximum readability and a "breathing" layout.

## Layout & Spacing

The layout follows a **Fixed-Sidebar, Fluid-Canvas** model derived from the initial sketch.

- **Sidebar (The Navigation):** A fixed 260px width vertical column on the left. It houses the user profile, main navigation categories (Bookshelf, Files, Settings), and a footer area for secondary tools.
- **Header (The Search):** A floating top bar that contains a pill-shaped search input. This bar should be semi-transparent on scroll to maintain context.
- **Main Content (The Bookshelf):** A multi-column grid that adapts to screen size. On desktop, it follows a 4-column structure. 
- **The "New Creation" Button:** Positioned prominently at the top right of the content area, creating a clear entry point for the primary task.

**Breakpoints:**
- **Mobile (<768px):** Sidebar collapses into a hamburger menu. The grid transitions to 1 or 2 columns. Safe margins reduce to 16px.
- **Desktop (>1200px):** Content area is capped at 1200px and centered to prevent line-lengths from becoming unreadable in the writing view.

## Elevation & Depth

To maintain a minimalist aesthetic, the design system avoids heavy shadows and traditional skeuomorphism. Instead, it uses **Tonal Layering and Soft Outlines**.

- **Level 0 (Base):** The parchment-colored background (#F9F8F6) of the application.
- **Level 1 (Surfaces):** Book cards and the writing canvas are pure white (#FFFFFF). They are separated from the background by a 1px solid border (#E5E1DA) rather than a shadow.
- **Interactive Depth:** Only when an element is hovered (like a book card) does a very soft, highly diffused ambient shadow appear (0px 4px 20px rgba(0, 0, 0, 0.04)).
- **Sidebar Seperator:** A 1px vertical line separates the sidebar from the content, echoing the bold structural lines in the provided sketch.

## Shapes

The shape language is **Soft and Architectural**. While the sketch indicates some organic hand-drawn loops, the professional system translates these into precise, subtle radii.

- **Cards & Sidebar Items:** Use a 4px (0.25rem) radius. This keeps the interface looking sharp and organized while removing the "stinging" feel of sharp corners.
- **Search Bar & Buttons:** Use a fully rounded "Pill" shape (999px) to provide a soft contrast to the grid-based book cards, making interactive elements instantly recognizable.
- **Book Covers:** Maintain a strictly rectangular 2:3 aspect ratio to mimic physical book dimensions.

## Components

### Buttons
- **Primary Action (New Creation):** Pill-shaped, secondary color (#6B8E23) background with white text. High contrast to ensure it's the first thing seen.
- **Ghost Buttons:** Used in the sidebar. No background, primary text color, highlighting with a soft parchment tint on hover.

### Book Cards
- A vertical container with a 2:3 aspect ratio image or solid color block.
- Title is placed directly below the card in `body-ui` bold.
- Progress indicators (e.g., word count) appear in `label-caps` in a muted gray.

### Input Fields (Search)
- A pill-shaped container with a light border. 
- The search icon should be placed on the left, using a stroke weight of 1.5px to match the refined typography.

### Sidebar Navigation
- Icons are minimal line-art. 
- The active state is indicated by a subtle vertical bar on the left edge and a weighted font style.

### Empty States
- When the bookshelf is empty, use a light-weight illustration of a blank page with a "Start your first chapter" call-to-action button.