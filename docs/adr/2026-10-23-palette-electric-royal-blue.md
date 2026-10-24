# Architecture Decision Record (ADR): Palette Transition to Electric Royal Blue

- **Date:** 2026-10-23
- **Status:** Pending Owner Confirmation
- **Target File:** `lib/core/theme/app_colors.dart`
- **Associated Commit:** `fbd160e`

---

## 1. Context & Commit Record

Commit `fbd160e` updated the global design token palette of the ECHO application.

- **Commit Hash:** `fbd160e`
- **Commit Message:** `"update loading page and global theme to Electric Royal Blue and Plus Jakarta Sans"`
- **Reason:** To be confirmed by the owner

---

## 2. Token Transitions

| Token Name | Old Hex Value (Pre-`fbd160e`) | New Hex Value (Post-`fbd160e`) | Contrast against Surface / White |
| :--- | :--- | :--- | :--- |
| `blue500` | `#1967B3` | `#005CE6` | 5.72:1 on White (WCAG AA), 5.02:1 on Blue100 |
| `blue400` | `#3B8ED8` | `#2E82F7` | 3.72:1 on White (WCAG 1.4.11 UI Components) |
| `blue100` | `#E1EEFA` | `#E8F1FF` | Subtle container and inactive pill fill |
| `textPrimary` | `#0D233A` | `#0A192F` | 17.60:1 on White (WCAG AAA) |
| `textSecondary` | `#4A6B8A` | `#48586E` | 7.25:1 on White (WCAG AAA) |

---

## 3. Decision & Invariants

1. **Strict Monochromatic Scheme:** The application uses strictly the monochromatic light-blue and white spectrum. No secondary off-palette hues (green, yellow, orange, red, purple) are permitted in production code.
2. **Typography Alignment:** While commit `fbd160e` mentioned Plus Jakarta Sans in its commit message, the codebase enforces `DM Sans` (`AppTypography.fontFamily = 'DMSans'`) as the single source of truth per project design guidelines.
3. **Owner Review:** Retained under active review pending final owner visual confirmation against the physical device display.
