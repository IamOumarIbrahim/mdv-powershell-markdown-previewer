# mdv-powershell-markdown-previewer

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207%2B-blue)
![Platform](https://img.shields.io/badge/platform-Windows-0078D6)
![Dark Mode](https://img.shields.io/badge/theme-GitHub%20Dark-0d1117)
![Obsidian](https://img.shields.io/badge/Obsidian-Properties-purple)
![LaTeX](https://img.shields.io/badge/math-KaTeX-green)

**Fast, Zero-Limit GitHub Dark Mode & Obsidian Properties Markdown Previewer for PowerShell.**

*Eliminates process argument overflow, binary path limits, and 32KB buffer caps.*

</div>

---

## Overview

`mdv-powershell-markdown-previewer` (`mdv`) provides high-performance, dark-mode Markdown rendering directly from the PowerShell command line. Standard CLI preview extensions (such as `gh markdown-preview`) rely on passing raw document strings directly via command-line flags. On Windows, this frequently triggers process creation errors (`fork/exec: filename or extension is too long`) whenever document payload size exceeds the 32,767-character `CreateProcess` argument buffer.

This module resolves process buffer caps and adds full support for Obsidian-style YAML Properties cards, embedded KaTeX LaTeX formulas, local image resolution, and simultaneous multi-document browser previewing (including recursive subfolder scanning).

---

## Key Capabilities

- **Zero-Limit Document Payload Sizing:** Renders large engineering specifications and documentation files without encountering Windows command-line process limits.
- **Obsidian-Style YAML Properties Cards:** Automatically parses YAML frontmatter (`---` ... `---`) into clean Obsidian Properties UI cards with pill badges for tags/aliases/authors, checkboxes for booleans, clickable links for URLs/DOIs, and structured key-value alignment.
- **GitHub Dark Mode Styling:** Renders documents using official GitHub Dark Theme CSS (`#0d1117`).
- **KaTeX LaTeX Math Rendering:** Parses inline (`$ ... $`, `\( ... \)`) and block (`$$ ... $$`, `\[ ... \]`) mathematical expressions natively.
- **Local Path Resolution:** Resolves relative image sources (`src="assets/..."`) and renders inline HTML elements (`<div align="center">`, badges, `<br />`).
- **Multi-Document Current Directory Preview (`mdv -all`):** Opens all Markdown files in the active directory simultaneously in individual browser tabs.
- **Recursive Subdirectory Preview (`mdv -allf`):** Recursively finds and opens all Markdown files across the current folder and all subdirectories (`-allf` / `-af`).

---

## Installation

### Method A: Single-Click Batch Installer
1. Clone or download this repository.
2. Double-click `install.bat`.
3. Open a new PowerShell terminal.

### Method B: PowerShell Web Installer
Execute the following command in PowerShell:

```powershell
iwr -useb https://raw.githubusercontent.com/IamOumarIbrahim/mdv-powershell-markdown-previewer/main/install.ps1 | iex
```

---

## Usage

### Preview a Single Document
```powershell
mdv README.md
```

### Preview All Documents in Current Directory Only
```powershell
mdv -all
```
*(or `mdv -a` or `mdv`)*

### Preview All Documents in Current Directory AND All Subdirectories
```powershell
mdv -allf
```
*(or `mdv -af`)*

---

## Technical Comparison

| Feature | `gh markdown-preview` | `mdv-powershell-markdown-previewer` |
| :--- | :---: | :---: |
| **Large File Support (>32 KB)** | Failed (`filename too long`) | **Zero Limit (Unlimited)** |
| **Obsidian YAML Properties UI** | Unrendered Raw Text Block | **Structured Properties Cards & Badges** |
| **LaTeX Math Rendering** | Unrendered Raw Text | **KaTeX Rendered** |
| **Local Image Resolution** | Broken Relative Paths | **Full Base URI Resolution** |
| **Inline HTML / Badges** | Escaped Text | **Native HTML Parsing** |
| **Current Directory Preview (`-all`)** | Unsupported / Empty `path=` | **Instant Multi-Tab Preview** |
| **Recursive Subdirectory Preview (`-allf`)** | Unsupported | **Full Recursive Scan & Render** |
| **Default Theme** | Light (Flag Required) | **GitHub Dark (`#0d1117`)** |

---

## License

Distributed under the [MIT License](LICENSE). Created and maintained by [Oumar Ibrahim](https://github.com/IamOumarIbrahim).
